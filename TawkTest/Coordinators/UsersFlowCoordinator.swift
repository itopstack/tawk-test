//
//  UsersFlowCoordinator.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit
import CoreData

protocol UsersFlowCoordinatorDelegate: AnyObject {
    
}

final class UsersFlowCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var parent: (Coordinator & UsersFlowCoordinatorDelegate)?

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
    
    private func pushToUserProfile(with user: GithubUser) {
        let vc = UserProfileViewController.instantiate(storyboardName: "UserProfile")
        let viewModel = UserProfileViewControllerViewModel(user: user)
        vc.viewModel = viewModel
        vc.coordinator = self
        vc.title = user.login
        navigationController.pushViewController(vc, animated: true)
    }
}

extension UsersFlowCoordinator: UserListViewControllerDelegate {
    func userListViewController(_ vc: UIViewController, didSelect user: GithubUser) {
        pushToUserProfile(with: user)
    }
}

extension UsersFlowCoordinator: UserProfileViewControllerDelegate {
    func userProfileViewController(_ vc: UserProfileViewController, didUpdate note: String, at userId: Int) {
        guard let userListViewController = (navigationController.viewControllers.first { $0 is UserListViewController }) as? UserListViewController else {
            return
        }
        
        for i in 0..<userListViewController.viewModel.users.count {
            let user = userListViewController.viewModel.users[i]
            if user.id == userId {
                userListViewController.viewModel.users[i].note = note
                break
            }
        }
    }
}
