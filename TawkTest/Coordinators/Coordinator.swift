//
//  Coordinator.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}

extension Coordinator {
    func addChild(_ coordnator: Coordinator) {
        childCoordinators.append(coordnator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        for i in 0..<childCoordinators.count {
            if childCoordinators[i] === coordinator {
                childCoordinators.remove(at: i)
                break
            }
        }
    }
}
