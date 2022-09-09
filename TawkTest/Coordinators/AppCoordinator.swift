//
//  AppCoordinator.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let userListCoordinator = UserListCoordinator(navigationController: navigationController)
        userListCoordinator.parent = self
        userListCoordinator.start()
        addChild(userListCoordinator)
    }
}

extension AppCoordinator: UserListCoordinatorDelegate {
    
}
