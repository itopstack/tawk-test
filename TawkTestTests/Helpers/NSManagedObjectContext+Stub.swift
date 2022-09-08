//
//  NSManagedObjectContext+Stub.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    static func alwaysFailingFetchStub() -> Stub {
        Stub(
            #selector(NSManagedObjectContext.__execute(_:)),
            #selector(Stub.execute(_:))
        )
    }

    static func alwaysFailingSaveStub() -> Stub {
        Stub(
            #selector(NSManagedObjectContext.save),
            #selector(Stub.save)
        )
    }

    final class Stub: NSObject {
        private let source: Selector
        private let destination: Selector

        init(_ source: Selector, _ destination: Selector) {
            self.source = source
            self.destination = destination
        }

        @objc func execute(_: Any) throws -> Any {
            throw anyError
        }

        @objc func save() throws {
            throw anyError
        }

        func startIntercepting() {
            method_exchangeImplementations(
                class_getInstanceMethod(NSManagedObjectContext.self, source)!,
                class_getInstanceMethod(Stub.self, destination)!
            )
        }

        deinit {
            method_exchangeImplementations(
                class_getInstanceMethod(Stub.self, destination)!,
                class_getInstanceMethod(NSManagedObjectContext.self, source)!
            )
        }
    }
}
