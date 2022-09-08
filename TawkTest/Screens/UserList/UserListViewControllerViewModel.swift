//
//  UserListViewControllerViewModel.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation

final class UserListViewControllerViewModel {
    private let service: UsersFetchable
    
    private(set) var userId = 0
    
    init(service: UsersFetchable = GithubService()) {
        self.service = service
    }
    
    func fetchUsers() {
        service.fetchUsers(since: userId) { [weak self] result in
            switch result {
            case let .success(users):
                self?.userId += 1
            case let .failure(error):
                break
            }
        }
    }
}
