//
//  UserProfileTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import XCTest
@testable import TawkTest

class UserProfileTests: XCTestCase {
    func test_decode_json() throws {
        let data = try XCTUnwrap(mockJsonString.data(using: .utf8))
        
        let sut = try JSONDecoder().decode(UserProfile.self, from: data)
        
        XCTAssertEqual(sut.avatarUrl, "https://avatars.githubusercontent.com/u/15520417?v=4")
        XCTAssertEqual(sut.bio, "my bio")
        XCTAssertNil(sut.email)
        XCTAssertEqual(sut.following, 3)
        XCTAssertEqual(sut.followers, 27)
        XCTAssertEqual(sut.publicRepos, 65)
        XCTAssertEqual(sut.login, "itopstack")
        XCTAssertEqual(sut.id, 15520417)
        XCTAssertEqual(sut.location, "Thailand")
        XCTAssertEqual(sut.name, "Kittisak Phetrungnapha")
    }
}

extension UserProfileTests {
    private var mockJsonString: String {
        """
        {
        "login": "itopstack",
        "id": 15520417,
        "node_id": "MDQ6VXNlcjE1NTIwNDE3",
        "avatar_url": "https://avatars.githubusercontent.com/u/15520417?v=4",
        "gravatar_id": "",
        "url": "https://api.github.com/users/itopstack",
        "html_url": "https://github.com/itopstack",
        "followers_url": "https://api.github.com/users/itopstack/followers",
        "following_url": "https://api.github.com/users/itopstack/following{/other_user}",
        "gists_url": "https://api.github.com/users/itopstack/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/itopstack/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/itopstack/subscriptions",
        "organizations_url": "https://api.github.com/users/itopstack/orgs",
        "repos_url": "https://api.github.com/users/itopstack/repos",
        "events_url": "https://api.github.com/users/itopstack/events{/privacy}",
        "received_events_url": "https://api.github.com/users/itopstack/received_events",
        "type": "User",
        "site_admin": false,
        "name": "Kittisak Phetrungnapha",
        "company": null,
        "blog": "https://itopstory.com/",
        "location": "Thailand",
        "email": null,
        "hireable": true,
        "bio": "my bio",
        "twitter_username": null,
        "public_repos": 65,
        "public_gists": 32,
        "followers": 27,
        "following": 3,
        "created_at": "2015-10-31T10:16:09Z",
        "updated_at": "2022-08-27T11:18:16Z"
        }
        """
    }
}
