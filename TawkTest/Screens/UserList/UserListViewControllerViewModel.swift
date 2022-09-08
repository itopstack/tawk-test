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
    private let service: UsersFetchable
    private weak var delegate: UserListViewControllerViewModelDelegate?
    
    private(set) var userId = 0
    private(set) var error: Error?
    private(set) var users: [GithubUser] = []
    
    init(service: UsersFetchable = GithubService(), delegate: UserListViewControllerViewModelDelegate) {
        self.service = service
        self.delegate = delegate
    }
    
    func fetchUsers() {
        service.fetchUsers(since: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(users):
                self.userId += 1
                self.users.append(contentsOf: users)
                self.delegate?.userListViewControllerViewModelDidFetchUsersSuccessfully(self)
                
            case let .failure(error):
                self.error = error
                self.delegate?.userListViewControllerViewModelDidFetchUsersFail(self, errorMessage: error.localizedDescription)
            }
        }
    }
}
