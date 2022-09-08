//
//  GithubService.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation

struct GithubService {
    func fetchUsers(since: Int, completion: @escaping (Result<[GithubUser], Error>) -> Void) {
        guard let url = URL(string: "https://api.github.com/users?since=\(since)") else {
            return completion(.failure(MyError.invalidURL))
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
        }.resume()
    }
}
