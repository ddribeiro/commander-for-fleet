//
//  Activities.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//

import Foundation

struct Activity: Codable, Identifiable {
    var id: Int
    var createdAt: Date
    var actorFullName: String

    struct Detail {
        var packID: Int?
        var packName: String?
        var policyId: Int?
        var policyName: String?
        var policies: Policy?
        var queryId: Int?
        var queryName: String?
        var queryIds: [Int]?
        
    }

    enum TypeEnum: String, Codable {
        case createdPack
        case editedPack
        case deletedPack
        case appliedSpecPack
        case createdPolicy
        case editedPolicy
        case deletedPolicy
        case appliedSpecPolicy
        case createdSavedQuery
        case editedSavedQuery
        case deletedSavedQuery
        case deletedMultipleSavedQuery
        case appliedSpecSavedQuery
        case createdTeam
        case deletedTeam
        case appliedSpecTeam
        case transferredHosts
        case editedAgentOptions
        case liveQuery
        case userAddedBySso
        case userLoggedIn
        case userFailedLogin
        case createdUser
        case deletedUser
        case changedUserGlobalRole
        case deletedUserGlobalRole
        case changedUserTeamRole
        case deletedUserTeamRole
        case mdmEnrolled
        case mdmUnenrolled
        case editedMacosMinVersion
        case editedWindowsUpdates
        case readHostDiskEncryptionKey
        case createdMacosProfile
        case deletedMacosProfile
        case editedMacosProfile
        case changedMacosSetupAssistant
        case deletedMacosSetupAssistant
        case enabledMacosDiskEncryption
        case disabledMacosDiskEncryption
        case addedBootstrapPackage
        case deletedBootstrapPackage
        case enabledMacosSetupEndUserAuth
        case disabledMacosSetupEndUserAuth
        case enabledWindowsMdm
        case disabledWindowsMdm
        case ranScript
        case addedScript
        case deletedScript
        case editedScript
        case createdWindowsProfile
        case deletedWindowsProfile
        case editedWindowsProfile
    }
}
