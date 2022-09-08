//
//  CoreDataStore.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation
import CoreData

enum RetrieveCachedResult {
    case empty
    case found(users: [GithubUser], timestamp: Date)
    case failure(Error)
}

typealias DeletionCompletion = (Error?) -> Void
typealias InsertionCompletion = (Error?) -> Void
typealias RetrievalCompletion = (RetrieveCachedResult) -> Void

final class CoreDataStore {
    static let modelName = "DataModel"
    static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataStore.self))

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let lock = NSLock()

    struct ModelNotFound: Error {
        let modelName: String
    }

    init(storeURL: URL) throws {
        guard let model = CoreDataStore.model else {
            throw ModelNotFound(modelName: CoreDataStore.modelName)
        }

        container = try NSPersistentContainer.load(
            name: CoreDataStore.modelName,
            model: model,
            url: storeURL
        )
        context = container.newBackgroundContext()
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait { [weak self] in
            guard let coordinator = self?.container.persistentStoreCoordinator else {
                return
            }
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(users: cache.localGithubUsers, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    func insert(_ users: [GithubUser], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { [weak self] context in
            self?.lock {
                do {
                    let managedCache = try ManagedCache.newUniqueInstance(in: context)
                    managedCache.timestamp = timestamp
                    managedCache.githubUsers = ManagedCache.managedGithubUsers(from: users, in: context)

                    try context.save()
                    completion(nil)
                } catch {
                    context.rollback()
                    completion(error)
                }
            }
        }
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { [weak self] context in
            self?.lock {
                do {
                    try ManagedCache.find(in: context).map(context.delete).map(context.save)
                    completion(nil)
                } catch {
                    context.rollback()
                    completion(error)
                }
            }
        }
    }

    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in action(context) }
    }
    
    private func lock(action: () -> Void) {
        lock.lock()
        action()
        lock.unlock()
    }
}
