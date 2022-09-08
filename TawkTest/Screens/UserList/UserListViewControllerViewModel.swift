//
//  UserListViewControllerViewModel.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation

protocol UserListViewControllerViewModelDelegate: AnyObject {
    func userListViewControllerViewModelDidFetchUsersSuccessfully(_ viewModel: UserListViewControllerViewModel)
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String)
}

final class UserListViewControllerViewModel {
    private let githubService: UsersFetchable
    private let localStorage: LocalStorage
    private weak var delegate: UserListViewControllerViewModelDelegate?
    
    private(set) var userId = 0
    private(set) var error: Error?
    private(set) var users: [GithubUser] = []
    
    init(service: UsersFetchable = GithubService(),
         localStorage: LocalStorage,
         delegate: UserListViewControllerViewModelDelegate) {
        self.githubService = service
        self.delegate = delegate
        self.localStorage = localStorage
    }
    
    func fetchUsers(timestamp: Date) {
        githubService.fetchUsers(since: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(users):
                self.userId += 1
                self.users.append(contentsOf: users)
                self.localStorage.insert(users, timestamp: timestamp) { _ in }
                self.delegate?.userListViewControllerViewModelDidFetchUsersSuccessfully(self)
                
            case let .failure(error):
                self.error = error
                self.delegate?.userListViewControllerViewModelDidFetchUsersFail(self, errorMessage: error.localizedDescription)
            }
        }
    }
}
