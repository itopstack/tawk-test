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
    private let imageDownloader: ImageDownloadable
    private weak var delegate: UserListViewControllerViewModelDelegate?
    
    private(set) var lastId = 0
    private(set) var error: Error?
    
    private(set) var users: [GithubUser] = [] {
        didSet {
            self.userCells = buildUserCells(from: users)
        }
    }
    
    private(set) var isDataFromCached = false
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
                if let note = user.note {
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
                if user.note != nil { // with note
                    userCell = .invertedNote(user)
                } else { // without note
                    userCell = .inverted(user)
                }
            } else { // normal cell
                if user.note != nil { // with note
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
                
                if self.isDataFromCached {
                    self.users = users
                } else {
                    self.users.append(contentsOf: users)
                }
                self.isDataFromCached = false
                
                self.localStorage.insert(self.users, timestamp: timestamp) { _ in }
                self.delegate?.userListViewControllerViewModelDidFetchUsersSuccessfully(self)
                
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
                self.isDataFromCached = true
                self.delegate?.userListViewControllerViewModelDidFetchUsersSuccessfully(self)
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
}
