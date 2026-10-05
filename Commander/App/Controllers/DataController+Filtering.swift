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

        results = applyStatusFilter(to: results, status: filterStatus)
        return sortHosts(results, by: sortType, oldestFirst: sortOldestFirst)
    }

    private func applyStatusFilter(to hosts: [Host], status: HostStatus) -> [Host] {
        switch status {
        case .all:
            return hosts
        case .online:
            return hosts.filter { $0.status.lowercased().contains("online") }
        case .offline:
            return hosts.filter { $0.status.lowercased().contains("offline") }
        case .missing:
            let missingThreshold = Date.now.addingTimeInterval(86400 * -30)
            return hosts.filter { $0.seenTime < missingThreshold }
        case .recentlyEnrolled:
            let enrolledThreshold = Date.now.addingTimeInterval(86400 * -7)
            return hosts.filter { $0.lastEnrolledAt > enrolledThreshold }
        }
    }

    private func sortHosts(_ hosts: [Host], by sortType: SortType, oldestFirst: Bool) -> [Host] {
        return hosts.sorted { lhs, rhs in
            switch sortType {
            case .name:
                let comparison = lhs.computerName.localizedCaseInsensitiveCompare(rhs.computerName)
                return oldestFirst ? comparison == .orderedAscending : comparison == .orderedDescending
            case .enrolledDate:
                return oldestFirst ? lhs.lastEnrolledAt < rhs.lastEnrolledAt : lhs.lastEnrolledAt > rhs.lastEnrolledAt
            case .updatedDate:
                return oldestFirst ? lhs.seenTime < rhs.seenTime : lhs.seenTime > rhs.seenTime
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
