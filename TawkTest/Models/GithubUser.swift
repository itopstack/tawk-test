//
//  GithubUser.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 7/9/2565 BE.
//

import Foundation

final class GithubUser: Equatable {
    let login: String
    let id: Int
    let avatarUrl: String
    let url: String
    let followersUrl: String
    let organizationsUrl: String
    let reposUrl: String
    let type: String
    let siteAdmin: Bool
    
    var hasSeen = false
    var note: String? = nil
    
    init(login: String,
         id: Int,
         avatarUrl: String,
         url: String,
         followersUrl: String,
         organizationsUrl: String,
         reposUrl: String,
         type: String,
         siteAdmin: Bool,
         hasSeen: Bool = false,
         note: String? = nil) {
        
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.url = url
        self.followersUrl = followersUrl
        self.organizationsUrl = organizationsUrl
        self.reposUrl = reposUrl
        self.type = type
        self.siteAdmin = siteAdmin
        self.hasSeen = hasSeen
        self.note = note
    }
    
    static let `default` = GithubUser(login: "", id: 0, avatarUrl: "", url: "", followersUrl: "", organizationsUrl: "", reposUrl: "", type: "", siteAdmin: false)
    
    static func == (lhs: GithubUser, rhs: GithubUser) -> Bool {
        lhs.login == rhs.login &&
        lhs.id == rhs.id &&
        lhs.avatarUrl == rhs.avatarUrl &&
        lhs.url == rhs.url &&
        lhs.followersUrl == rhs.followersUrl &&
        lhs.organizationsUrl == rhs.organizationsUrl &&
        lhs.reposUrl == rhs.reposUrl &&
        lhs.type == rhs.type &&
        lhs.siteAdmin == rhs.siteAdmin &&
        lhs.hasSeen == rhs.hasSeen &&
        lhs.note == rhs.note
    }
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
