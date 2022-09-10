//
//  UserProfileViewControllerViewModel.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import Foundation

protocol UserProfileViewControllerViewModelDelegate: AnyObject {
    
}

final class UserProfileViewControllerViewModel {
    private let user: GithubUser
    private weak var delegate: UserProfileViewControllerViewModelDelegate?
    
    init(user: GithubUser, delegate: UserProfileViewControllerViewModelDelegate) {
        self.user = user
        self.delegate = delegate
    }
}
