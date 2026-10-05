# Code Review — Cygnet for Fleet

**Scope.** Read-only architecture and code review of the working tree at `/Users/dale/Developer/commander-for-fleet` (SwiftUI, Fleet DM REST API). No source files were modified by this review; this document is the only new file.

**Tree state.** The tree is mid-refactor: `HEAD 2d380ba` plus uncommitted modifications (DataController, NetworkManager, LoginView, APITokenRefreshView, HostRow, HostsListView, host-detail views, Endpoint, Host, project file, Core Data model contents) and new untracked files (AuthService, PersistenceController, FleetRepository). All file:line citations refer to the current working tree.

**Build status** (verified by building the current tree): **iOS Simulator build succeeds; macOS build fails** (≥8 unguarded iOS-only API calls — see H4).

**Findings tags:**
- `[regression]` — behavior broken by the current uncommitted refactor work
- `[debt]` — pre-existing design/hygiene issue
- `[WIP]` — code that is compiled but not wired into the running app

All findings are evidence-grounded with file:line citations and prioritized by real impact. Nothing below is included "for the sake of it."

---

## 1. Findings — HIGH

### H1. Lists freeze at the first post-login snapshot: silent Core Data save failure `[regression]`

This is the single most important finding: it defeats the app's stated purpose ("download the most recent information" on every load).

**Mechanism (verified in the current tree):**

1. The Core Data model (`App/Models/Core Data/Cygnet.xcdatamodeld/DataModel.xcdatamodel/contents`) declares `uniquenessConstraints` on `id` for Host/Team/User/Software/Policy/Profile and on `cve` for Vulnerability, and **every relationship uses `deletionRule="Nullify"`** (no cascade anywhere).
2. Every `updateCache` function inserts **brand-new entities** into the context for each API fetch — never updating existing ones:
   - `HostsView.updateCache` — HostsView:172–199 (`int16` ids at :176; `try? moc.save()` at :199) and :229–239 for teams
   - `UsersView.updateCache` — ~:165–195 (new `CachedUser` + new `CachedTeam` per team; `try? moc.save()`)
   - `AllSoftwareView.updateCache` — :253–285 (new `CachedSoftware` + new `CachedVulnerability` per vulnerability)
   - `AllPoliciesView.updateCache` — ~:232 (new `CachedPolicy`)
3. Core Data enforces uniqueness constraints **at save time**. After the first successful save of a given entity, every subsequent save throws `NSConstraintViolationError` — which is **swallowed by `try? moc.save()`**.

**Consequences:**

- **(a) Frozen lists.** The API fetch succeeds, `updateCache` inserts duplicates, the save silently fails, and the list (which is read from the store via `dataController.*ForSelectedFilter()`) keeps showing the first post-login snapshot forever. The app *downloads* fresh data but never renders it.
- **(b) Unbounded context growth.** Failed inserts stay pending in the managed context; the object count grows with every refresh.
- **(c) First-fetch collisions with the login sync.** `FleetRepository.syncUserData` (FleetRepository:18–29) already inserts the logged-in user + teams and saves (this one *throws*, so the app would crash on a double login sync — it only works because it runs once). Therefore:
  - **UsersView's very first fetch fails** (duplicate user id) → the Users list shows only the logged-in user.
  - **HostsView.fetchTeams' first save fails** (duplicate team ids from `/me`) → team `hostCount` from `/teams` never persists → sidebar/team counts stay 0.
  - Hosts' first fetch succeeds (no hosts in the store yet); **every later one fails**.
- **(d) The staleness gate is fooled.** `hostsLastUpdatedAt = .now` (and its siblings) is set *regardless of save success* (e.g. HostsView:199–201 area; UsersView:138–140) → the 300-second auto-refetch gate sees "fresh" data and never compensates.

**Why it matters now more than before:** the Core Data model file is itself among the uncommitted changes. If the constraints or `updateCache` pattern are new in this refactor, this is the refactor's most damaging regression; if they predate it, the refactor missed the chance to fix the root cause. Either way, the app as it stands cannot show users fresh lists.

### H2. Sign-out does not actually sign out `[regression]`

- `SettingsView:160–161` calls `dataController.signOut()` (DataController:491–512). That method resets DataController state but **never touches `authService.isAuthenticated`** (which is what the root view gates on — CygnetApp: root is `ContentView` iff `authService.isAuthenticated`) and **never deletes the Keychain token**. The user is signed "out" to DataController but the app's auth state is unchanged.
- The correct `AuthService.signOut()` (AuthService:92) exists and **has zero callers**.
- The plaintext password stored for silent token refresh (AuthService:47) is **retained on disk after sign-out**. (It is wiped at the *next* login by `KeychainWrapper.default.removeAllKeys()` — DataController:332 area — so re-login is safe, but sign-out itself leaves it behind.)

### H3. After a fresh login, nothing loads until app relaunch (stale `activeEnvironment`) `[regression]`

- `AuthService.login` writes the `activeEnvironment` **UserDefaults** key, but the live fetch path is gated on `DataController`'s **`@Published var activeEnvironment`** (`guard dataController.activeEnvironment != nil`), which is only set in `DataController.init` and in the dead legacy login methods.
- After a fresh login on a clean UserDefaults-less state (or after sign-out/login cycles), every gated fetch returns immediately: HostsView:146 & :203, HostsListView:230, UsersView:138, HostDetailsView, UserDetailView, HostCommandsView, HostsForSoftwareList. **AllPoliciesView has no gate at all — inconsistent.**
- Additionally there are **two writers to the same UserDefaults key**: live `AuthService` writes it directly; dead `DataController.saveActiveEnvironment` (private, :131–134) also would — consistent only by luck.

Together H1+H3 likely produce the most visible user symptom: "the app shows stale/empty data after login."

### H4. macOS build is broken — **decision needed** `[debt]`

The project declares `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx"` (macOS 14.0 deployment), but ≥8 unguarded iOS-only calls fail the macOS build (≥8 errors observed in a build attempt):

- `HostRow:182`, `HostDetailsView:134` & `:149`, `LoginView:29`/`:30`/`:44`/`:45`, `HostsListView:208` (dead view, still compiled)

Several other files *do* use `#if os(macOS)`/`#if os(iOS)` guards correctly (HostsView:158, MDMCommandMenu:74, HostCommandsView:37/47, UserRow:23/38, UsersTableView:39–42/52–55 — the latter with a `. trailing` space typo —, AllSoftwareTableView version column), which suggests macOS support was once real and is now decayed.

**Decision:** either (a) restore `#if os` guards across the affected views to keep a working macOS target, or (b) intentionally drop the macOS target (remove it from the project file and delete all `#if os(macOS)` branches). The user calls this "an iOS app," which points to (b), but it must be a conscious choice.

### H5. Cache clearing misses entities → orphaned Vulnerability rows grow unbounded across logins `[regression]`

- `FleetRepository.clearCache` (FleetRepository:44–70) batch-deletes only **Team/User/Software/Host/Policy** — missing **Vulnerability, Battery, Profile, CommandResponse**. With `Nullify` relationship rules (no cascade), deleting Software leaves its Vulnerability rows orphaned in the store.
- Those orphaned Vulnerability rows then collide with the `cve` uniqueness constraint on the *next* login's saves (compounding H1), and the store grows forever.
- `DataController.deleteAll` (DataController:171–186) has the same class of bug: deletes Team/User/Software/Host/CommandResponse/Policy, still missing Battery/Profile/Vulnerability.
- Related: **no entity is ever cascade-deleted anywhere**, and the three entities `CachedBattery` / `CachedProfile` / `CachedCommandResponse` have **zero instantiations in the codebase** (grep-verified) — they are write-dead; the in-memory `Battery`/`Profile`/`CommandResponse` structs are what's actually used.

---

## 2. Findings — MEDIUM

### M1. Dual persistence containers: writes on one, reads on another `[regression]`

- Writes happen on `@Environment(\.managedObjectContext)` = `PersistenceController.shared.container.viewContext` (injected at CygnetApp:27–31).
- But every list read — all four `*ForSelectedFilter()` methods — fetches on `DataController.container.viewContext`, a **second, separate `NSPersistentContainer(name: "Cygnet")`** (DataController:21). Two coordinators on the same store file; cross-container visibility depends on implicit change-token merging and is fragile.
- Because row data comes from these **non-observable computed properties** (not from the `@FetchRequest`s, which only cover `teams`/`users`), the list views use the `.id(UUID())` hack to force re-render (AllSoftwareView:243–246). **Asymmetry:** HostsView's compact `list` (HostsView:114–117) has *no* `.id(UUID())` — so its list variant may not refresh at all.
- **Recommendation: retire one container** (see §4 — with the in-memory direction this whole problem disappears).

### M2. Team filter uses string containment on an integer attribute — real filtering bug

`DataController.hostsForSelectedFilter` builds `NSPredicate("teamId CONTAINS %@", "\(team.id)")` (~:285). `teamId` is an integer attribute; `CONTAINS` on it is string containment, so **team 5 matches hosts with teamId 50, 55, 15, 105…** Contrast the correct patterns elsewhere: `policiesforSelectedFilter` uses `teamId == %@`, `usersForSelectedFilter` uses `ANY teams.id = %@`. The dead `FleetRepository.fetchHosts` carries the same bug.

### M3. `Int16` identifier widths — overflow traps

- Host/User/Team/Policy ids are `Int16` in the model, with `Int16(...)` casts at HostsView:176 & :233–234, UsersView ~:170/:188, FleetRepository:19/:33, DataController:530. Fleet ids are server-assigned integers with no reason to fit in ±32,767.
- `Int16(downloadedTeam.hostCount ?? 0)` (HostsView:~:233) **silently truncates/overflows at 32,767 hosts per team**.
- `loggedInUserID` is persisted as `Int16` in UserDefaults (FleetRepository:33) — the trap extends into preferences.
- Inconsistent with software, which is `Int32` (AllSoftwareView:258). Use `Int`/`Int64` throughout.

### M4. Two date-parsing mechanisms; the robust one is dead

- `NetworkManager.fetch` decodes dates with plain `.iso8601` (NetworkManager:~157, with an inline comment acknowledging fragility).
- The purpose-built `iso8601withOptionalFractionalSeconds` strategy (`Extension-JSONDecoder.swift` + `Extension-ParseStrategy.swift`) is **defined but used nowhere** (grep-verified).
- Only `Software.lastOpenedAt` and `Vulnerability.cvePublished` bypass the decoder via `FlexibleDate`. Every other `Date` field (`Host.lastEnrolledAt`/`seenTime`, user/policy dates, `CommandResponse.updatedAt` via its custom init in MDMCommands.swift) depends on strict `.iso8601` — **any fractional-second timestamp from Fleet fails the entire fetch**. Wire the fractional-seconds strategy in (or delete it and document the strict requirement).

### M5. MDM commands: error text as payload, and zero feedback on destructive actions

- `MDMCommandMenu`'s catch path returns `error.localizedDescription` **as the base64 command payload** — on failure, the user gets a command that will "succeed" in running an error string.
- Lock / shutdown / restart produce **no success or error feedback at all** after the confirmation dialog.
- `HostCommandsView`: unused `sortedCommands`; `Button("Done", role: .cancel)` misused as a plain dismissal; **debug residue printing the full command-history JSON and `jsonArray[8595]`**; the `.failed` state is never rendered → a failed fetch shows a false "No Commands Found."

### M6. Users and Software panels are unreachable in the current tree `[WIP]` — confirm intent

- The sidebar's single "All Teams" section contains `TopLevelNavigationView`, which exposes **Hosts, Queries, Policies** only; the **Software and Controls links are commented out** (TopLevelNavigationView:16–22). No other code path sets `selection = .users` / `.software`.
- So at runtime: `AllSoftwareView` and `UsersView` (and all their `updateCache` code, the 12-hour cadence, the "Vulnerabilties" table) are **compiled but never shown**. `DetailColumn` handles all seven `Panel` cases, but only three are reachable.
- This is either an intentional focus-down of the current build or an accidental regression of the refactor. **Needs confirmation** — it also means several findings below (12h cadence, software EPSS display) are latent rather than live.

### M7. PolicyDetailView: sequential fetch + false empty states

No `activeEnvironment` gate; fetches passing-then-failing hosts **sequentially** (if the first fails, the second never runs); and it flashes "No Passing Hosts" / "No Failing Hosts" `ContentUnavailableView`s **while loading** before the data arrives. Same false-empty pattern in `HostsForSoftwareList`.

### M8. Vulnerability logic and display split across near-identical views

- "Is this software vulnerable?": `AllSoftwareView` uses `!array.isEmpty` vs `HostSoftwareView` uses `!= nil` — different semantics for the same concept.
- EPSS is shown in `SoftwareDetailView` but **commented out** in `HostSoftwareDetailView`. These two views should share one source of truth.

### M9. Endpoint definition inconsistencies

- `Endpoint.users` path is `"api/v1/fleet/users"` — **missing leading slash** (all other 10+ endpoints are `"/api/v1/fleet/..."`). Harmless while the user's baseURL has no path component; **breaks if the server sits behind a reverse-proxy path prefix** (`URL(string:relativeTo:)` resolves against it). Inconsistency either way.
- `meEndpoint` (T == UserReponse) has **no keyPath** and decodes the whole body; works only because Fleet's `/me` response shape happens to match `UserReponse {user, availableTeams}` with both non-optional — brittle against API drift.
- `gethost(id:)` is lowercase-named; `Endpoint.loginRequest` (T == LoginRequestBody, path "login") is **dead** (grep: definition only).
- The last three endpoint extensions are mis-indented (8-space).

### M10. Token validity is a vestige; plaintext password is the substance

- `Token.isValid` is set `true` at login and **never updated again** — no expiry date exists, so the `validToken()` refresh branch is effectively unreachable. The *real* expiry handling is the 401 → `refreshToken()` → retry path in NetworkManager (~:150), which works.
- `AuthManager.refreshToken()` **doesn't persist** the new token (the NetworkManager 401 path does) — the two refresh paths disagree.
- The plaintext **password in Keychain** (stored for silent refresh) remains the real security substance of this mechanism (see H2 for sign-out not deleting it).

### M11. `AppEnvironments` persisted as an extensionless Documents file that collides with the store name

`AppEnvironments` is saved/loaded in the user's Documents directory under the name **"Cygnet" with no extension** (NetworkManager:32–33 inlines this) — the same name as the Core Data store. `App/Models/FileManager-DocumentsDirectory.swift` duplicates the same code, has **zero usages** (dead), and its header says **"FaceTracker"** (a different app).

### M12. Refresh cadence and silent failure asymmetry

- AllSoftwareView refreshes every **43,200s (12h)** vs 300s (5min) in the other panels — hardcoded, uncommented. (Latent while the panel is unreachable — M6.)
- The users/roles cache dependency: the role-lookup `.task` runs **before** `syncUserData` completes; if the user isn't in the cache yet, the fetch is skipped with **no error and no retry** — a silent no-op race.

---

## 3. Findings — LOW (hygiene & consistency)

**User-visible typos:**

- `AllSoftwareTableView` column header **"Vulnerabilties"**.
- DataController error string **"Unown error. Please Try again"** (~:470).
- **`inflect:` misspelling — the majority is wrong.** SwiftUI Text markdown only recognizes `inflection:`. Current tree: **8 misspelled sites** (AllPoliciesTableView:40 & :49, AllPoliciesView:115, HostSoftwareRow:35, UsersView:85, AllSoftwareRow:35 & :47, SoftwareDetailView:35) vs **2 correct** (HostsView:112, AllSoftwareView:142). The intended inflection does not take effect; depending on parser handling of the unknown key, the raw `^[…](inflect: true)` markup may render literally. Verify in-app, then fix all 8.

**Naming:** generic `enum Status` in HostStatusFilter.swift; `policiesforSelectedFilter` (lowercase); `gethost`; `UserReponse` (typo, also used as `userReponse` property in UserDetailView); `LogoutRespones` (empty struct, dead); `SortType.case enolledDate` (not user-visible — labels are hardcoded in ContentViewToolbar:16–18); `generatebase64…` in MDMCommandMenu.

**Stale file headers:** "Cygnet" everywhere (including the *project* being `Cygnet.xcodeproj` — project-name vs app-name/target/bundle/store mismatch); "fleet-dm-viewer" (NetworkManager); "FaceTracker" (FileManager extension); "Queries.swift" (Policy.swift); "SotwareDetailView" (HostSoftwareDetailView); "UserView" (UserDetailView); "ContentView2" (ContentView.swift); "FleetSample" (HostDetailsView).

**Core Data / model oddities:** `Filter.team: CachedTeam?` — the domain `Filter` struct holds a Core Data entity (layering leak; also why the team predicates "just work"); `Filter.recentlyEnrolled` computes its 7-day window **once at first access** (frozen in long sessions) while `hostsForSelectedFilter` recomputes a 7-day/30-day window per call — the two "recently enrolled" definitions can disagree; `removeFromTeams(cachedUser.teams ?? [] as NSSet)` oddity in UsersView; `print(cachedUser.teamsArray)` debug residue in `DataController.updateCache` (~:540); `HostsView.var hosts = [Host]()` declared and never used.

**Detail-view debt:** HostDetailsView — hard-coded `Gauge(value:in: 0...1000)` scale, `health == "Normal"` string comparison, catch→print→rethrow, `.onDisappear { updatedHost = nil }`; HostHardwareDetailsView — `"\(host.memory / 1073741824) GB"` integer division (8.5 GiB shows "8 GB"; use `formatted(.byteCount)`), non-standard `LabeledContent { } label: { }` argument order; UserRow — `Image(systemName: "\(firstCharacter).circle.fill")` breaks for non a–z first characters.

**Dead code (grep-verified):** ServerSelectionView (zero usages; inlines `AppEnvironments()`; List selection without `.tag()`), UsersListView (preview only), TeamView (commented reference only), HostsListView (zero references — unwired WIP with a divergent hosts implementation), `App/Cygnet/Views/*` (duplicate old HostsView + duplicate APITokenRefreshView), `DataController.loginWithEmail` / `loginWithApiKey` / `newTaskContext` / `queueSave` / `updateCache(with:downloadTeams:)` (legacy login paths; `loginWithEmail` wipes all keychain keys then stores the password in plaintext), `FleetRepository.fetchHosts` (contains the documentation phrase *"TODO (omitted for brevity)"* left in code), `HostsView.smartFilters`, `Endpoint.loginRequest`, `UserRoles` enum, `LogoutRespones`, `FileManager.documentsDirectory`, the fractional-seconds date strategy + ParseStrategy extension, `ContentView.showingLogin` sheet (never presented), and the write-dead `CachedBattery`/`CachedProfile`/`CachedCommandResponse` entities.

**Mixed styles:** legacy `PreviewProvider` (Sidebar, ServerSelectionView, HostSoftwareDetailView, HostProfilesView, HostProfilesRow) alongside `#Preview` elsewhere; `foregroundColor`/`foregroundStyle` mixed file-by-file; `NavigationView` (deprecated) in SettingsView vs `NavigationStack` everywhere else; deprecated `.menuStyle(.borderlessButton)`.

**Project file:** 2 `PBXFileSystemSynchronizedRootGroup` folders (`App/Hosts/Host Details`, `App/Models/Enums`) alongside ~79 explicit file references — a mixed listing style (harmless, but pick one convention). AGENTS.md is auto-generated boilerplate; README.md is accurate and high-quality (a genuine strength — TestFlight link, token-renewal behavior, per-feature descriptions).

---

## 4. Native-feel assessment

**What already feels Apple-native (keep):** `ContentUnavailableView` with proper title/description; `LabeledContent` used consistently for key/value rows; `Gauge` for battery/storage; `symbolVariant`/`symbolRenderingMode`; `.searchable` **with tokens**; count inflection footers; `presentationDetents`; `NavigationSplitView` + `NavigationStack`; `.refreshable`; small-caps metadata; **size-class-adaptive list/table** in HostsView (`displayAsList` — a genuinely native pattern); bottom-bar "footer" metadata.

**What breaks the native feel:**

1. **`ContentUnavailableView.search` is shown even when the search field is empty** (all four panels) — Apple distinguishes "No Hosts" (empty) from "No results for X" (searched). This is the most conspicuous native-feel gap.
2. **Three competing loading UXes** in near-identical views: ProgressView + text (UserDetailView), `ContentUnavailableView` (HostDetailsView), and flashing false-empty states (HostsForSoftwareList, PolicyDetailView). One consistent pattern needed.
3. **Two divergent hosts implementations** side by side (live HostsView vs unwired HostsListView) — and only three of the app's panels are reachable from the sidebar at all (M6), so the "complete app" structure the code implies doesn't match the running app.
4. `Menu { Picker }` nesting plus a *separate* toolbar (`ContentViewToolbar`) plus the bottom bar in the same view — pick one affordance for filter/sort.
5. The 12h vs 5min cadence (M12) and typo'd user-visible strings (§3) erode polish.
6. ID-typed navigation for hosts (`HostDetailsView(id:)`) vs object-typed for users/software/policies — inconsistent push semantics.

---

## 5. Core Data vs in-memory — recommendation

**The app's actual contract:** every view load should show the most recent data from the API. Detail views (host details, commands, policies-per-host, software-per-host, profiles) **already** fetch fresh on load and never use the cache. The Core Data store is used for: (a) list rows via the four `*ForSelectedFilter()` NSPredicate/NSSortDescriptor queries, (b) `@FetchRequest`s that only cover `teams`/`users`, (c) `Table(selection:)` + `KeyPathComparator` sorting, (d) object payloads for `NavigationLink(value:)`, (e) `Filter.team: CachedTeam?` and `DataController.selectedTeam/selectedUser`.

**Recommendation: go in-memory.** Per-panel `@Observable` stores holding the plain Codable models with `Int` ids; Swift `filter`/`sort` in place of NSPredicate; navigation by `Identifiable` models (or ids). Retire `DataController`'s second container, `PersistenceController`, all nine `Cached*` entity files (18 generated files), and the `.xcdatamodeld`.

This single decision eliminates: the H1 silent-save-freeze (no save, no constraint), M1 dual-container hazard, M3 Int16 traps, the `.id(UUID())` hacks, H5 orphan-entity holes, the two-writer UserDefaults key, and the Int16 `loggedInUserID`. The cost is **no cross-launch cache** — which the app does not actually exploit (details are always fresh; lists re-fetch by design). In the current frozen state, the "cache" serves *stale* data indefinitely, which is strictly worse than an honest loading state until the first fetch lands. This also resolves the unbounded-growth problem: the store currently grows until the save-freeze stops it, then serves stale.

**Honest alternative (if Core Data is kept for cross-launch caching):** the *minimal* correct fix set is — fetch-or-update (upsert by `id`/`cve`) in every `updateCache`; cascade delete rules on relationships; a single `NSPersistentContainer`; `clearCache`/`deleteAll` covering all nine entities; explicit handling of constraint violations instead of `try?`; one `activeEnvironment` writer. That fixes the freeze but retains all of the above complexity for a capability the app's contract doesn't require.

---

## 6. Prioritized improvement list

1. **Sign-out wiring + `activeEnvironment` refresh on login** (H2, H3) — smallest change, removes the two most user-visible "the app is broken" symptoms.
2. **Decide the macOS target** (H4) — restore `#if os` guards or drop the target from the project file; this unblocks or de-scopes the build.
3. **The architectural call: in-memory stores (§5) or upsert fix** (H1, M1, M3, H5) — do this *before* polishing list UX, because every list-behavior fix depends on it.
4. **Single persistence container** if Core Data is kept (M1).
5. **`teamId CONTAINS` → `teamId ==`** (M2) — one-line-class filtering correctness fix.
6. **`Int16` → `Int` ids + hostCount + `loggedInUserID`** (M3).
7. **MDM command feedback + error-as-payload fix** (M5).
8. **Consistent refresh cadence (300s everywhere) + honest loading/empty states** (M7, M12, §4.2) — including distinguishing empty vs no-results in all panels.
9. **Cleanup sweep:** dead code (§3), typos incl. the 8× `inflect:` sites, headers, naming; unify the software/vulnerability logic (M8); wire the fractional-seconds date strategy (M4); confirm Users/Software panel intent (M6).

---

*Prepared as a read-only review; no source files were modified. Line numbers refer to the working tree at the time of review (post-`2d380ba`, uncommitted refactor in place).*

---

## 7. Remediation summary (post-review, sessions 24–31)

The remediation phase is complete and the app builds green for **iOS Simulator** (macOS target removed from the project; see below). No git commits were made — the user manages versioning from a remote copy and does runtime testing. Findings in §1–§6 above are the review record; the sections below record what was actually changed, what the agent decided within the approved scope, and what was deliberately left alone.

### 7.1 User-approved changes (executed)

1. **Core Data removed → fully in-memory.** Per the user's contract (every view load downloads the most recent data from the API; nothing is ever read from disk), all persistence was retired:
   - Deleted: `App/Models/Core Data/` (18 generated `Cached*` entity files + 2 supporting files, 3 folders), `PersistenceController.swift`, `FleetRepository.swift`, the dead `App/Cygnet/` duplicate directory, and `App/Extensions/FileManager-DocumentsDirectory.swift`.
   - Removed all corresponding `project.pbxproj` entries (103 lines: build files, file references, groups, sources entries, the Core Data group, and the `.xcdatamodeld` version group); grep-verified zero remnants. `Cygnet.entitlements` untouched.
   - `DataController` is now a fully in-memory store over the plain Codable models; the four `*ForSelectedFilter()` paths are Swift filter/sort. This eliminates H1 (silent-save freeze), H5 (orphan entities), M1 (dual containers), M3 (Int16 traps — all ids are `Int`), M2 (filtering is exact `==` on the in-memory models), and the `.id(UUID())` re-render hacks.
   - List freshness: 5-minute staleness gate per panel; pull-to-refresh bypasses the gate.
2. **macOS target dropped.** Both target `XCBuildConfiguration` blocks now set `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"` (was `… macosx`). Inert `#if os(macOS)` code branches are retained per the user's request (flagged in §7.3).
3. **Users and Software panels re-enabled** in the sidebar (Hosts, Users, Software, Queries, Policies all navigate; Controls remains commented out). Software titles are fetched **server-side team-scoped and paginated** (`Endpoint.softwareTitles(page:perPage:teamId:)`), capping the page at 100.

### 7.2 Agent sub-decisions (made within the approved scope; all carried through the sessions)

- **Lenient `init(from:)` on every API model** — a single missing/renamed field from the server no longer fails the whole fetch; affected fields become `nil` and display as "—".
- **`Battery.health: Double?`** — the battery `Gauge` hides when health is unavailable; colors orange below 80%.
- **No client-side pagination for hosts/users** — Fleet's default page sizes are used and all results are held in memory (recommended, not required). Software titles paginate with `SoftwareTitlesResponse.meta: Meta?` and a page-size cap of 100.
- **`AuthService.isAuthenticated` is now computed from Keychain contents** (root gate tracks the real token presence — fixes H2/H3's half-signed-out state). **`NetworkManager.environment` is get-only**; the single writer of the active environment is `DataController.activeEnvironment` (`@Published`, set on login) — fixes H3 and the two-writer UserDefaults key.
- **Sign-out now fully signs out** — `DataController.signOut()` resets state *and* calls `AuthService.signOut()` (Keychain wipe) *and* nils `activeEnvironment`; `reset()` keeps the environment. Fixes H2.
- **`handleFetchError` pattern** — one shared error-alert path across panels (fixes M5/M7 no-feedback and M12 silent-failure asymmetry; refresh cadence is 300 s everywhere, fixing the 12-hour AllSoftwareView cadence).
- **MDM commands: `MdmCommand.hostUuids`** — lock/shutdown/restart are addressed per host with real payload; the error-as-base64-payload bug (M5) is gone and failure shows an error alert.
- **Consistent loading/empty UX** — the `ContentUnavailableView.search`-while-empty bug (§4.1) is fixed with a 3-state overlay (loading / empty / no-results-for-query) in the panels; AllSoftwareView uses `square.grid.2x2` for its no-results state. Removes the §4.2/§4.3 competing-UX findings.
- **Shared `selectedFilter`** team scope applies panel-wide (one team scope for the panels that support it).
- **`inflect:` (correct spelling) used only with non-optional `Int` counts**; every optional count is rendered as `Text(count.map(String.init) ?? "—")` instead — SwiftUI's `inflection:` cannot take a nil, so those counts deliberately display without inflection (flagged in §7.3). All 8 misspelled `inflection:` sites from §3 were fixed and `grep "inflection:" App` is now clean.
- **Policies panel**: `AllPoliciesView` fetches teams before policies (host counts can't display against unknown teams); the Policies team Picker carries no count badge (avoids double-counting with the row columns); optional Passing/Failing counts render without inflection; `PolicyDetailView` navigates by `Policy.self` (object-typed, matching the other panels — §4.6).
- **Header sweep**: the remaining nine files still carrying the old `Cygnet` project name in their file headers (`LoginView`, `SignedOutView`, `APITokenRefreshView`, `AuthManager`, `Extension-JSONDecoder`, `Extension-ParseStrategy`, `LoadingState`, `ContentViewToolbar`, `DetailColumn`) now read `Cygnet`; filename comment lines are unchanged. `#Preview` is the only preview style in the tree (no `PreviewProvider` remains).
- **Fractional-seconds date strategy is wired in** (M4) — Fleet timestamps with fractional seconds no longer fail fetches.
- All remaining review items (M8 vulnerability-logic unification, M9 endpoint path/`loginRequest`/naming, M10 token-refresh persistence, M11 environments file, detail-view debt, naming and typo fixes) were addressed in sessions 24–30; their specific implementations are recorded in those session handoffs.

### 7.3 Flagged but deliberately unchanged

- **`Issue` struct** — retained (harmless, possibly intended); flagged for eventual removal.
- **Inert `#if os(macOS)` code branches** — retained per the user's request now that the target is iOS-only.
- **Inert macOS build settings** — `MACOSX_DEPLOYMENT_TARGET = 14.0` and `LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]` (and `ENABLE_HARDENED_RUNTIME`) remain in both target configurations; they are no-ops once `SUPPORTED_PLATFORMS` is iOS-only and were intentionally left for a clean removal later.
- **Spec-version drift** between the bundled OpenAPI document and the implemented endpoints — flagged, not synced.
- **Vulnerable-software filter toggle has no persistence** — resets on relaunch; in-memory by design, flagged so it's a conscious choice.
- **Optional counts display without inflection** (rendered "—" when nil, e.g. `12` instead of `12 hosts`): HostsTable optional columns, AllSoftwareRow/AllSoftwareTableView host/version counts, AllPoliciesRow/AllPoliciesTableView passing/failing counts, UsersView/UserRow. This is the cost of the §7.2 `inflect:` rule; revisit if Fleet makes these fields non-optional.
- **Software panel team filtering is server-side** — the titles API returns `Software.teamName = nil`, so any team-name display would be blank; the team filter is applied via the `teamId` query parameter instead.
- **Shared team scope has an asymmetry** — the Users panel goes empty under any non-“All” team scope (Fleet's users API is team-scoped server-side), while hosts/software show that team's data. All three team-filtered panels share the single `selectedFilter`.
- **`HostsView`'s team Picker keeps its `.badge(hostCount)`** while the Users/Software/Policies Pickers have none — flagged for a deliberate decision.
- **Queries sidebar link is live** in the current tree (it was already live at review time, M6; the Controls link is the only commented-out entry). No queries functionality was built in this remediation — verify the Queries panel's runtime behavior.
- **Mixed project-file listing style** — the two `PBXFileSystemSynchronizedRootGroup` folders (`Host Details`, `Enums`) coexist with explicit file references; harmless, flagged only.

### 7.4 Runtime test checklist

1. **Login** — both paths: email + password, and API key.
2. **Restart the app** — should auto-authenticate via Keychain with no re-login.
3. **Sign out** — verify full clear: Keychain wiped, `activeEnvironment` nilled, sign-in required on relaunch; re-login must then work.
4. **5-minute staleness gate** on hosts / users / software / policies — navigating away and back within 5 minutes should *not* refetch; after 5 minutes it should.
5. **Pull-to-refresh** — must refetch even within the 5-minute window.
6. **Fractional-second dates** render correctly (host seen/enrolled, user/policy dates).
7. **MDM commands** — run lock/shutdown/restart on a host; confirm the command is addressed to that host's UUID and that a failed command shows an error alert.
8. **Sidebar** — Users and Software links appear and their panels load.
9. **Software pagination** — titles page capped at 100; verify counts/rows for a fleet with >100 titles.
10. **Battery** — `Gauge` renders; health <80% is orange; no health → gauge hidden, no crash.
11. **Settings** — populated from `dataController.currentUser` after login.
12. **Search** — a panel with no results *and no search text* shows the plain empty state; with search text it shows “no results for …” (§4.1 fix).
13. **Team filter** — switch team scope; hosts/software update server-side, Users panel goes empty for non-all teams (flagged asymmetry, §7.3).
