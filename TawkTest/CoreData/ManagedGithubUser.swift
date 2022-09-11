//
//  ManagedGithubUser.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation
import CoreData

@objc(ManagedGithubUser)
final class ManagedGithubUser: NSManagedObject {
    @NSManaged var login: String
    @NSManaged var id: Int
    @NSManaged var avatarUrl: String
    @NSManaged var url: String
    @NSManaged var followersUrl: String
    @NSManaged var organizationsUrl: String
    @NSManaged var reposUrl: String
    @NSManaged var type: String
    @NSManaged var siteAdmin: Bool
    @NSManaged var hasSeen: Bool
    @NSManaged var note: String
}

extension ManagedGithubUser {
    var localGithubUser: GithubUser {
        GithubUser(
            login: login,
            id: id,
            avatarUrl: avatarUrl,
            url: url,
            followersUrl: followersUrl,
            organizationsUrl: organizationsUrl,
            reposUrl: reposUrl,
            type: type,
            siteAdmin: siteAdmin,
            hasSeen: hasSeen,
            note: note
        )
    }
}
