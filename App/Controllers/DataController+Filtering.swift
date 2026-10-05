import Foundation
import SwiftUI

extension DataController {
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
