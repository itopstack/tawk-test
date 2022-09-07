//
//  GithubUser.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 7/9/2565 BE.
//

import Foundation

struct GithubUser {
    let login: String
    let id: Int
    let avatarUrl: String
    let url: String
    let followersUrl: String
    let organizationsUrl: String
    let reposUrl: String
    let type: String
    let siteAdmin: Bool
}

extension GithubUser: Codable {
    private enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case url
        case followersUrl = "followers_url"
        case organizationsUrl = "organizations_url"
        case reposUrl = "repos_url"
        case type
        case siteAdmin = "site_admin"
    }
}
