//
//  ManagedCache.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation
import CoreData

@objc(ManagedCache)
final class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var githubUsers: NSOrderedSet
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }

    var localGithubUsers: [GithubUser] {
        githubUsers.compactMap { $0 as? ManagedGithubUser }.map { $0.localGithubUser }
    }

    static func managedGithubUsers(from localGithubUsers: [GithubUser], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: localGithubUsers.map({ local in
            let managed = ManagedGithubUser(context: context)
            managed.id = local.id
            managed.login = local.login
            managed.avatarUrl = local.avatarUrl
            managed.url = local.url
            managed.followersUrl = local.followersUrl
            managed.organizationsUrl = local.organizationsUrl
            managed.reposUrl = local.reposUrl
            managed.type = local.type
            managed.siteAdmin = local.siteAdmin
            managed.hasSeen = local.hasSeen
            managed.note = local.note
            return managed
        }))
    }
}
