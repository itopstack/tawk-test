//
//  UserListCoordinator.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

protocol UserListCoordinatorDelegate: AnyObject {
    
}

final class UserListCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var parent: (Coordinator & UserListCoordinatorDelegate)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = UserListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}

extension UserListCoordinator: UserListViewControllerDelegate {
    
}
