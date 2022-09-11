//
//  GithubService.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation

protocol UsersFetchable: AnyObject {
    func fetchUsers(since: Int, completion: @escaping (Result<[GithubUser], Error>) -> Void)
}

protocol ProfileFetchable: AnyObject {
    func fetchUserProfile(from urlString: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
}

final class GithubService: UsersFetchable, ProfileFetchable {
    private let session: Requestable
    
    init(session: Requestable = URLSession.shared) {
        self.session = session
    }
    
    func fetchUsers(since: Int, completion: @escaping (Result<[GithubUser], Error>) -> Void) {
        guard let url = URL(string: "https://api.github.com/users?since=\(since)") else {
            return completion(.failure(MyError.invalidURL))
        }
        
        session.request(with: url) { data, response, error in
            var result: Result<[GithubUser], Error>?
            defer {
                DispatchQueue.main.async {
                    if let result = result {
                        completion(result)
                    } else {
                        completion(.failure(MyError.missingResult))
                    }
                }
            }
            
            if let error = error {
                result = .failure(error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
                result = .failure(MyError.invalidStatusCode)
                return
            }
            
            guard let data = data else {
                result = .failure(MyError.missingData)
                return
            }
            
            do {
                let users = try JSONDecoder().decode([GithubUser].self, from: data)
                result = .success(users)
            } catch {
                result = .failure(error)
            }
        }
    }
    
    func fetchUserProfile(from urlString: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            return completion(.failure(MyError.invalidURL))
        }
        
        session.request(with: url) { data, response, error in
            var result: Result<UserProfile, Error>?
            defer {
                DispatchQueue.main.async {
                    if let result = result {
                        completion(result)
                    } else {
                        completion(.failure(MyError.missingResult))
                    }
                }
            }
            
            if let error = error {
                result = .failure(error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
                result = .failure(MyError.invalidStatusCode)
                return
            }
            
            guard let data = data else {
                result = .failure(MyError.missingData)
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                result = .success(profile)
            } catch {
                result = .failure(error)
            }
        }
    }
}

protocol Requestable: AnyObject {
    func request(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: Requestable {
    func request(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: url, completionHandler: completion).resume()
    }
}
