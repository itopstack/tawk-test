//
//  UserListCoordinator.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit
import CoreData

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
        let storeDirectory = NSPersistentContainer.defaultDirectoryURL()
        let url = storeDirectory.appendingPathComponent("TawkTest.sqlite")
        guard let localStorage = try? CoreDataStore(storeURL: url) else {
            fatalError("Cannot initiate local storage")
        }
        
        let vc = UserListViewController()
        let viewModel = UserListViewControllerViewModel(localStorage: localStorage, delegate: vc)
        vc.viewModel = viewModel
        vc.coordinator = self
        vc.title = "Github Users"
        navigationController.pushViewController(vc, animated: false)
    }
}

extension UserListCoordinator: UserListViewControllerDelegate {
    func userListViewController(_ vc: UIViewController, didSelect user: GithubUser) {
        
    }
}
