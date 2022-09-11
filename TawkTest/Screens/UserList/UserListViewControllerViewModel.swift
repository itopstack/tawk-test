//
//  UserListViewControllerViewModel.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation

protocol UserListViewControllerViewModelDelegate: AnyObject {
    func userListViewControllerViewModelDidUpdateUsersSuccessfully(_ viewModel: UserListViewControllerViewModel)
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String)
}

final class UserListViewControllerViewModel {
    private let githubService: UsersFetchable
    private let localStorage: LocalStorage
    private let imageDownloader: ImageDownloadable
    private weak var delegate: UserListViewControllerViewModelDelegate?
    
    private(set) var lastId = 0
    private(set) var error: Error?
    
    // single source of truth
    var users: [GithubUser] = [] {
        didSet {
            userCells = buildUserCells(from: users)
            delegate?.userListViewControllerViewModelDidUpdateUsersSuccessfully(self)
        }
    }
    
    private(set) var userCells: [[UserCell]] = []
    
    var filteredUserCells: [[UserCell]] {
        if searchText.isEmpty {
            return userCells
        } else {
            let searchText = searchText.lowercased()
            let filteredUsers = users.filter { user in
                if user.login.lowercased().contains(searchText) {
                    return true
                }
                
                let note = user.note
                if !note.isEmpty {
                    return note.lowercased().contains(searchText)
                }
                return false
            }
            
            let filteredUserCells = buildUserCells(from: filteredUsers)
            return filteredUserCells
        }
    }
    
    var searchText = ""
    
    init(service: UsersFetchable = GithubService(),
         localStorage: LocalStorage,
         imageDowdloader: ImageDownloadable = ImageDownloader.shared,
         delegate: UserListViewControllerViewModelDelegate) {
        self.githubService = service
        self.delegate = delegate
        self.imageDownloader = imageDowdloader
        self.localStorage = localStorage
    }
    
    private func buildUserCells(from users: [GithubUser]) -> [[UserCell]] {
        var userCells: [[UserCell]] = []
        
        for i in 0..<users.count {
            let user = users[i]
            let userCell: UserCell
            
            if i % 4 == 3 { // inverted cell
                if !user.note.isEmpty { // with note
                    userCell = .invertedNote(user)
                } else { // without note
                    userCell = .inverted(user)
                }
            } else { // normal cell
                if !user.note.isEmpty { // with note
                    userCell = .note(user)
                } else { // without note
                    userCell = .normal(user)
                }
            }
            
            userCells.append([userCell])
        }
        
        return userCells
    }
    
    func fetchUsers(timestamp: Date) {
        githubService.fetchUsers(since: lastId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(users):
                if let lastId = users.last?.id {
                    self.lastId = lastId
                }
                
                var tmp = self.users
                for i in 0..<users.count {
                    var newUser = users[i]
                    
                    // If data that come from api is exactly the same with local storage, we do not need to insert new user to our data source, we just copy note from previous to new one
                    if tmp.contains(newUser) {
                        newUser.note = tmp[i].note
                        tmp[i] = newUser
                    } else {
                        tmp.append(newUser)
                    }
                }
                
                if tmp != self.users {
                    self.users = tmp
                    self.localStorage.insert(self.users, timestamp: timestamp) { _ in }
                }
                
            case let .failure(error):
                self.error = error
                self.delegate?.userListViewControllerViewModelDidFetchUsersFail(self, errorMessage: error.localizedDescription)
            }
        }
    }
    
    func retrieveCached() {
        localStorage.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .found(users, _):
                self.users = users
                self.delegate?.userListViewControllerViewModelDidUpdateUsersSuccessfully(self)
            case .failure, .empty:
                break
            }
        }
    }
    
    func fetchAvatar(from urlString: String, completion: @escaping (Data?) -> Void) {
        imageDownloader.fetch(from: urlString, completion: completion)
    }
    
    func numberOfSections() -> Int {
        filteredUserCells.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        filteredUserCells[section].count
    }
    
    func userCell(for indexPath: IndexPath) -> UserCell {
        filteredUserCells[indexPath.section][indexPath.row]
    }
    
    func heightForRowAt(indexPath: IndexPath) -> Float {
        76.0
    }
    
    func heightForFooter(in section: Int) -> Float {
        8.0
    }
    
    var allowLoadMore: Bool {
        searchText.isEmpty
    }
    
    func updateNote(_ note: String, at index: Int, timestamp: Date) {
        users[index].note = note
        localStorage.insert(users, timestamp: timestamp) { _ in } // Update database with user's note
    }
}
