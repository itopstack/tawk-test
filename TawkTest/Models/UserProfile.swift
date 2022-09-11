//
//  UserProfile.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import Foundation

struct UserProfile: Codable {
    let login: String
    let id: Int
    let avatarUrl: String
    let name: String
    let location: String?
    let email: String?
    let bio: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    
    private enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case name
        case location
        case email
        case bio
        case publicRepos = "public_repos"
        case followers
        case following
    }
}
