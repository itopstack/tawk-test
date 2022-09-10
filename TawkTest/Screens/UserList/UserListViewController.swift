//
//  UserListViewController.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

protocol UserListViewControllerDelegate: AnyObject {
    func userListViewController(_ vc: UIViewController, didSelect user: GithubUser)
}

final class UserListViewController: UITableViewController, UISearchResultsUpdating {
    weak var coordinator: (Coordinator & UserListViewControllerDelegate)?
    var viewModel: UserListViewControllerViewModel!
    
    private lazy var resultSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(viewModel != nil, "ViewModel is missing, please assign it to view controller first")
        
        view.backgroundColor = .white
        
        UserCell.allCases.forEach { userCell in
            tableView.register(userCell.cellClass, forCellReuseIdentifier: userCell.cellIdentifier)
        }
        tableView.register(SpacingView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(SpacingView.self)) // for spacing view between each cell
        tableView.separatorColor = .clear
        tableView.tableHeaderView = resultSearchController.searchBar
        
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
        let user = userCell.user
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell.cellIdentifier, for: indexPath) as? CellConfigurable
        cell?.configure(with: user)
        
        viewModel.fetchAvatar(from: user.avatarUrl) { cell?.updateAvatarImage(from: $0) }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.userCell(for: indexPath).user
        coordinator?.userListViewController(self, didSelect: selectedUser)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(viewModel.heightForRowAt(indexPath: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat(viewModel.heightForFooter(in: section))
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(SpacingView.self))
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard viewModel.allowLoadMore else { return }
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            tableView.tableFooterView = spinner
            
            viewModel.fetchUsers(timestamp: Date())
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            viewModel.searchText = text
            tableView.reloadData()
        }
    }
}

// MARK: - UserListViewControllerViewModelDelegate

extension UserListViewController: UserListViewControllerViewModelDelegate {
    func userListViewControllerViewModelDidFetchUsersSuccessfully(_ viewModel: UserListViewControllerViewModel) {
        tableView.reloadData()
        tableView.tableFooterView = nil
    }
    
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String) {
        
    }
}
