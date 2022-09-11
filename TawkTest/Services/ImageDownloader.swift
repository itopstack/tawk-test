//
//  ImageDownloader.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import Foundation

protocol ImageDownloadable: AnyObject {
    func fetch(from urlString: String, completion: @escaping (Data?) -> Void)
}

final class ImageDownloader: ImageDownloadable {
    static let shared = ImageDownloader()
    
    var session: Requestable = URLSession.shared
    private var cached: [String: Data] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    func fetch(from urlString: String, completion: @escaping (Data?) -> Void) {
        lock.lock()
        let cached = cached[urlString]
        lock.unlock()
        
        if let data = cached {
            return completion(data)
        }
        
        guard let url = URL(string: urlString) else {
            return completion(nil)
        }
        
        session.request(with: url) { [weak self] data, _, _ in
            if let data = data {
                self?.lock.lock() // Prevent race condition
                self?.cached[urlString] = data
                self?.lock.unlock()
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
}

