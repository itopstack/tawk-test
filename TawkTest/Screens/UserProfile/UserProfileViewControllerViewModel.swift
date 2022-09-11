//
//  UserProfileViewControllerViewModel.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import Foundation

final class UserProfileViewControllerViewModel {
    private let user: GithubUser
    private let githubService: ProfileFetchable
    private let imageDownloader: ImageDownloadable
    
    private(set) var userProfile: UserProfile!
    
    init(user: GithubUser,
         githubService: ProfileFetchable,
         imageDownloader: ImageDownloadable = ImageDownloader.shared) {
        self.user = user
        self.githubService = githubService
        self.imageDownloader = imageDownloader
    }
    
    var followers: String {
        "followers: \(userProfile.followers)"
    }
    
    var following: String {
        "following: \(userProfile.following)"
    }
    
    var name: String {
        "name: \(userProfile.name)"
    }
    
    var email: String {
        if let email = userProfile.email {
            return "email: \(email)"
        }
        return "email: -"
    }
    
    var location: String {
        if let location = userProfile.location {
            return "location: \(location)"
        }
        return "location: -"
    }
    
    var repos: String {
        "public repository: \(userProfile.publicRepos)"
    }
    
    var bio: String {
        if let bio = userProfile.bio {
            return "bio: \(bio)"
        }
        return "bio: -"
    }
    
    var note: String? {
        user.note
    }
    
    func fetchUserProfile(completion: @escaping (_ errorMessage: String?) -> Void) {
        githubService.fetchUserProfile(from: user.url) { [weak self] result in
            switch result {
            case let .success(profile):
                self?.userProfile = profile
                completion(nil)
            case let .failure(error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func loadProfileImage(completion: @escaping (Data?) -> Void) {
        imageDownloader.fetch(from: userProfile.avatarUrl, completion: completion)
    }
}
