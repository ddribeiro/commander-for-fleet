//
//  DataController.swift
//  Commander
//
//  Created by Dale Ribeiro on 8/21/23.
//

import Foundation
import SwiftUI

/* Central store for state shared across the app.
 All data is held in memory only; nothing is persisted to disk.
 Views fetch fresh data from the Fleet API whenever they need it. */
@MainActor
class DataController: ObservableObject {
    let networkManager: NetworkManager

    // The active environment. AuthService is the sole writer of the
    // persisted copy; it is surfaced here for views that inspect it.
    @Published var activeEnvironment: AppEnvironment?

    // In-memory data.
    @Published var hosts: [Host] = []
    @Published var teams: [Team] = []
    @Published var users: [User] = []
    @Published var software: [Software] = []
    @Published var policies: [Policy] = []
    @Published var currentUser: User?

    // Filtering and sorting.
    @Published var selectedFilter = Filter.all
    @Published var filterText = ""
    @Published var filterTokens = [SearchToken]()
    @Published var filterStatus: HostStatus = .all
    @Published var sortOldestFirst = true
    @Published var sortType: SortType = .name

    // Alerts.
    @Published var showingAlert = false
    @Published var showingApiTokenAlert = false
    @Published var apiTokenText = ""
    @Published var alertTitle = ""
    @Published var alertDescription = ""

    // Last-updated timestamps; drive the refresh gates in each view.
    @Published var teamsLastUpdatedAt: Date?
    @Published var hostsLastUpdatedAt: Date?
    @Published var usersLastUpdatedAt: Date?
    @Published var softwareLastUpdatedAt: Date?
    @Published var policiesLastUpdatedAt: Date?

    @Published var allTokens = [
        SearchToken(name: "macOS", platform: ["darwin"]),
        SearchToken(name: "Windows", platform: ["windows"]),
        SearchToken(name: "Linux", platform: ["rhel", "ubuntu"])
    ]

    @Published var loadingState = LoadingState.loaded

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager

        if let data = UserDefaults.standard.data(forKey: "activeEnvironment") {
            self.activeEnvironment = try? JSONDecoder().decode(AppEnvironment.self, from: data)
        }
    }

    // MARK: - Environment

    func validateServerURL(_ urlString: String) throws -> String {
        guard !urlString.isEmpty else {
            throw URLError(.badURL)
        }

        guard let url = URL(string: urlString), url.scheme != nil else {
            return "https://" + urlString
        }

        return urlString
    }

    // MARK: - State management

    /// Loads the logged-in user's data and clears stale results
    /// from the previous session.
    func syncLoginData(user: User?, teams: [Team]) {
        currentUser = user
        self.teams = teams

        hosts = []
        users = []
        software = []
        policies = []

        teamsLastUpdatedAt = nil
        hostsLastUpdatedAt = nil
        usersLastUpdatedAt = nil
        softwareLastUpdatedAt = nil
        policiesLastUpdatedAt = nil

        selectedFilter = .all
        filterText = ""
        filterTokens = []
        filterStatus = .all
        sortOldestFirst = true
        sortType = .name
        apiTokenText = ""
    }

    /// Clears all in-memory data, leaving the active environment intact.
    func reset() {
        syncLoginData(user: nil, teams: [])
    }

    // MARK: - Fetching

    func updateTeams() async {
        guard activeEnvironment != nil else { return }

        loadingState = .loading
        do {
            teams = try await networkManager.fetch(.teams, attempts: 5)
            teamsLastUpdatedAt = .now
            loadingState = .loaded
        } catch {
            handleFetchError(error)
        }
    }

    func updateHosts() async {
        guard activeEnvironment != nil else { return }

        loadingState = .loading
        do {
            hosts = try await networkManager.fetch(.hosts, attempts: 5)
            hostsLastUpdatedAt = .now
            loadingState = .loaded
        } catch {
            handleFetchError(error)
        }
    }

    func updateUsers() async {
        guard activeEnvironment != nil else { return }

        loadingState = .loading
        do {
            users = try await networkManager.fetch(.users, attempts: 5)
            usersLastUpdatedAt = .now
            loadingState = .loaded
        } catch {
            handleFetchError(error)
        }
    }

    /// Fetches global policies plus the policies of each visible team.
    func updatePolicies() async {
        guard activeEnvironment != nil else { return }

        loadingState = .loading
        do {
            var all = try await networkManager.fetch(.globalPolicies, attempts: 5).policies ?? []
            var seen = Set(all.map { $0.id })

            for team in teams {
                guard let teamPolicies = try? await networkManager.fetch(
                    .getTeamPolicies(id: team.id),
                    attempts: 5
                ) else { continue }

                for policy in teamPolicies.policies ?? [] where seen.insert(policy.id).inserted {
                    all.append(policy)
                }
            }

            policies = all
            policiesLastUpdatedAt = .now
            loadingState = .loaded
        } catch {
            handleFetchError(error)
        }
    }

    /// The team scope (`team_id`) of the last successful software titles fetch;
    /// `nil` means all teams. Detects a changed team scope when a view loads.
    var softwareTeamId: Int?

    /// Fetches software titles (optionally scoped to a single team), following
    /// pagination until exhausted.
    func updateSoftware(teamId: Int? = nil) async {
        guard activeEnvironment != nil else { return }

        loadingState = .loading
        do {
            var all: [Software] = []
            var seen = Set<Int>()
            let perPage = 50
            var page = 1

            // Defensive cap in case a server keeps reporting more results.
            while page <= 100 {
                let response = try await networkManager.fetch(
                    .softwareTitles(page: page, perPage: perPage, teamId: teamId),
                    attempts: 5
                )

                let titles = response.softwareTitles ?? []
                for title in titles where seen.insert(title.id).inserted {
                    all.append(title)
                }

                // Fall back to page size when the server omits `meta`.
                let hasNext = response.meta?.hasNextResults ?? (titles.count == perPage)
                if !hasNext || titles.isEmpty {
                    break
                }

                page += 1
            }

            software = all
            softwareTeamId = teamId
            softwareLastUpdatedAt = .now
            loadingState = .loaded
        } catch {
            handleFetchError(error)
        }
    }

    /* A failed fetch either surfaces a token issue or marks the load as
     failed; the last good data is kept either way. */
    private func handleFetchError(_ error: Error) {
        if let authError = error as? AuthManager.AuthError,
           case .missingCredentials = authError {
            apiTokenText = ""
            showingApiTokenAlert = true
            return
        }

        loadingState = .failed
    }

    // MARK: - Filtering

    func hostsForSelectedFilter() -> [Host] {
        var results = hosts

        if let team = selectedFilter.team {
            results = results.filter { $0.teamId == team.id }
        } else if selectedFilter.minEnrollmentDate > Date.distantPast {
            results = results.filter { $0.lastEnrolledAt > selectedFilter.minEnrollmentDate }
        }

        let trimmed = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            results = results.filter {
                $0.computerName.localizedCaseInsensitiveContains(trimmed)
                    || $0.hardwareSerial.localizedCaseInsensitiveContains(trimmed)
            }
        }

        if !filterTokens.isEmpty {
            let platforms = filterTokens.flatMap { $0.platform }.map { $0.lowercased() }
            results = results.filter { host in
                let platform = host.platform.lowercased()
                return platforms.contains { platform.contains($0) }
            }
        }

        switch filterStatus {
        case .all:
            break
        case .online:
            results = results.filter { $0.status.lowercased().contains("online") }
        case .offline:
            results = results.filter { $0.status.lowercased().contains("offline") }
        case .missing:
            // swiftlint:disable:next line_length
            let missingThreshold = Date.now.addingTimeInterval(86400 * -30)
            results = results.filter { $0.seenTime < missingThreshold }
        case .recentlyEnrolled:
            let enrolledThreshold = Date.now.addingTimeInterval(86400 * -7)
            results = results.filter { $0.lastEnrolledAt > enrolledThreshold }
        }

        return results.sorted { lhs, rhs in
            switch sortType {
            case .name:
                let comparison = lhs.computerName.localizedCaseInsensitiveCompare(rhs.computerName)
                return sortOldestFirst ? comparison == .orderedAscending
                    : comparison == .orderedDescending
            case .enrolledDate:
                return sortOldestFirst ? lhs.lastEnrolledAt < rhs.lastEnrolledAt
                    : lhs.lastEnrolledAt > rhs.lastEnrolledAt
            case .updatedDate:
                return sortOldestFirst ? lhs.seenTime < rhs.seenTime
                    : lhs.seenTime > rhs.seenTime
            }
        }
    }

    func usersForSelectedFilter() -> [User] {
        var results = users

        if let team = selectedFilter.team {
            results = results.filter {
                $0.teams.contains { $0.id == team.id } || $0.teams.isEmpty
            }
        }

        let trimmed = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed)
                    || $0.email.localizedCaseInsensitiveContains(trimmed)
            }
        }

        return results.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func softwareForSelectedFilter() -> [Software] {
        var results = software

        let trimmed = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            results = results.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
        }

        return results.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func policiesForSelectedFilter() -> [Policy] {
        var results = policies

        if let team = selectedFilter.team {
            results = results.filter { $0.teamId == team.id }
        }

        let trimmed = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed)
                    || $0.authorName.localizedCaseInsensitiveContains(trimmed)
            }
        }

        return results
    }
}
