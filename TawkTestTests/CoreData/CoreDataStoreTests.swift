//
//  CoreDataStoreTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import XCTest
import CoreData
@testable import TawkTest

class CoreDataStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        let sut = try makeSUT()
        let users = uniqueUsers()
        let timestamp = Date()

        insert((users, timestamp), to: sut)

        expect(sut, toRetrieve: .found(users: users, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        let sut = try makeSUT()
        let users = uniqueUsers()
        let timestamp = Date()

        insert((users, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(users: users, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureOnRetrievalError() throws {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()

        let sut = try makeSUT()

        expect(sut, toRetrieve: .failure(anyError))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()

        let sut = try makeSUT()

        expect(sut, toRetrieveTwice: .failure(anyError))
    }

    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()

        let insertionError = insert((uniqueUsers(), Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        insert((uniqueUsers(), Date()), to: sut)

        let insertionError = insert((uniqueUsers(), Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()
        insert((uniqueUsers(), Date()), to: sut)
        let latestUsers = uniqueUsers()
        let latestTimestamp = Date()
        
        insert((latestUsers, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .found(users: latestUsers, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        let sut = try makeSUT()

        let insertionError = insert((uniqueUsers(), Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_insert_hasNoSideEffectsOnInsertionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        let sut = try makeSUT()

        insert((uniqueUsers(), Date()), to: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        insert((uniqueUsers(), Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }

    func test_delete_emptiesPreviouslyInsertedCache() throws {
        let sut = try makeSUT()
        insert((uniqueUsers(), Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversErrorOnDeletionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let users = uniqueUsers()
        let timestamp = Date()
        let sut = try makeSUT()
        insert((users, timestamp), to: sut)
        stub.startIntercepting()

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let users = uniqueUsers()
        let timestamp = Date()
        let sut = try makeSUT()
        insert((users, timestamp), to: sut)
        stub.startIntercepting()

        deleteCache(from: sut)

        expect(sut, toRetrieve: .found(users: users, timestamp: timestamp))
    }

    func test_delete_removesAllObjects() throws {
        let store = try makeSUT()
        insert((uniqueUsers(), Date()), to: store)

        deleteCache(from: store)

        let context = try NSPersistentContainer.load(
            name: CoreDataStore.modelName,
            model: XCTUnwrap(CoreDataStore.model),
            url: inMemoryStoreURL()
        ).viewContext

        let existingObjects = try context.allExistingObjects()

        XCTAssertEqual(existingObjects, [], "found orphaned objects in Core Data")
    }

    func test_storeSideEffects_runSerially() throws {
        let sut = try makeSUT()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueUsers(), timestamp: Date()) { _ in
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedUsers { _ in
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueUsers(), timestamp: Date()) { _ in
            op3.fulfill()
        }

        let op4 = expectation(description: "Operation 4")
        sut.retrieve { _ in
            op4.fulfill()
        }

        wait(for: [op1, op2, op3, op4], timeout: 5.0, enforceOrder: true)
    }

    func test_imageEntity_properties() throws {
        let entity = try XCTUnwrap(
            CoreDataStore.model?.entitiesByName["ManagedGithubUser"]
        )

        entity.verify(attribute: "login", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "id", hasType: .integer64AttributeType, isOptional: false)
        entity.verify(attribute: "avatarUrl", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "url", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "followersUrl", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "organizationsUrl", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "reposUrl", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "type", hasType: .stringAttributeType, isOptional: false)
        entity.verify(attribute: "siteAdmin", hasType: .booleanAttributeType, isOptional: false)
        entity.verify(attribute: "hasSeen", hasType: .booleanAttributeType, isOptional: false)
        entity.verify(attribute: "note", hasType: .stringAttributeType, isOptional: false)
    }

    // - MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> CoreDataStore {
        let sut = try CoreDataStore(storeURL: inMemoryStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func inMemoryStoreURL() -> URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }
}

extension CoreDataStore.ModelNotFound: CustomStringConvertible {
    public var description: String {
        "Core Data Model '\(modelName).xcdatamodeld' not found. You need to create it in the production target."
    }
}

extension XCTestCase {
    @discardableResult
    func insert(_ cache: (users: [GithubUser], timestamp: Date), to sut: CoreDataStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.users, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: CoreDataStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedUsers { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    func expect(_ sut: CoreDataStore, toRetrieveTwice expectedResult: RetrieveCachedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: CoreDataStore, toRetrieve expectedResult: RetrieveCachedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break

            case let (.found(expectedUsers, expectedTimestamp), .found(retrievedUsers, retrievedTimestamp)):
                XCTAssertEqual(retrievedUsers, expectedUsers, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)

            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
