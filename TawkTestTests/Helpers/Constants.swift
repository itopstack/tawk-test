//
//  Constants.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation
@testable import TawkTest

let anyError = NSError(domain: "any-error", code: 123, userInfo: [NSLocalizedDescriptionKey: "any error"])
let anyURL = URL(string: "https://any-url.com")!

func uniqueUsers() -> [GithubUser] {
    [uniqueUser(), uniqueUser()]
}

var count = 0
func uniqueUser() -> GithubUser {
    defer {
        count += 1
    }
    
    return GithubUser(
        login: "itopstack_\(count)",
        id: 15520417,
        avatarUrl: "https://avatars.githubusercontent.com/u/15520417?v=4",
        url: "https://api.github.com/users/itopstack",
        followersUrl: "https://api.github.com/users/itopstack/followers",
        organizationsUrl: "https://api.github.com/users/itopstack/orgs",
        reposUrl: "https://api.github.com/users/itopstack/repos",
        type: "User",
        siteAdmin: false
    )
}
