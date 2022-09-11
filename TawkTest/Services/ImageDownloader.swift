//
//  ImageDownloader.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import Foundation

protocol Cachable: AnyObject {
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
}
extension URLCache: Cachable {}

protocol ImageDownloadable: AnyObject {
    func fetch(from urlString: String, completion: @escaping (Data?) -> Void)
}

final class ImageDownloader: ImageDownloadable {
    static let shared = ImageDownloader()
    
    var session: Requestable = URLSession.shared
    var cache: Cachable = URLCache.shared
    
    private var cached: [String: Data] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    func fetch(from urlString: String, completion: @escaping (Data?) -> Void) {
        lock.lock()
        let cached = cached[urlString]
        lock.unlock()
        
        // local cache
        if let data = cached {
            return completion(data)
        }
        
        guard let url = URL(string: urlString) else {
            return completion(nil)
        }
        
        // disk cache
        if let data = cache.cachedResponse(for: URLRequest(url: url))?.data {
            updateCached(for: urlString, data: data)
            return completion(data)
        }
        
        session.request(with: url) { [weak self] data, _, _ in
            if let data = data {
                self?.updateCached(for: urlString, data: data)
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    private func updateCached(for urlString: String, data: Data) {
        lock.lock() // Prevent race condition
        cached[urlString] = data
        lock.unlock()
    }
}
