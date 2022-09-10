//
//  UserListViewController.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

protocol UserListViewControllerDelegate: AnyObject {
    
}

final class UserListViewController: UITableViewController {
    weak var coordinator: (Coordinator & UserListViewControllerDelegate)?
    var viewModel: UserListViewControllerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(viewModel != nil, "ViewModel is missing, please assign it to view controller first")
        
        view.backgroundColor = .white
        
        UserCell.allCases.forEach { userCell in
            tableView.register(userCell.cellClass, forCellReuseIdentifier: userCell.cellIdentifier)
        }
        
        viewModel.fetchUsers(timestamp: Date())
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = viewModel.userCell(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell.cellIdentifier, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - UserListViewControllerViewModelDelegate

extension UserListViewController: UserListViewControllerViewModelDelegate {
    func userListViewControllerViewModelDidFetchUsersSuccessfully(_ viewModel: UserListViewControllerViewModel) {
        tableView.reloadData()
    }
    
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String) {
        
    }
}
