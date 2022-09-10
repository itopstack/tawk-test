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
    private let session: Requestable
    private var cached: [String: Data] = [:]
    private let lock = NSLock()
    
    init(session: Requestable = URLSession.shared) {
        self.session = session
    }
    
    func fetch(from urlString: String, completion: @escaping (Data?) -> Void) {
        if let data = cached[urlString] {
            return completion(data)
        }
        
        guard let url = URL(string: urlString) else {
            return completion(nil)
        }
        
        lock.lock()
        session.request(with: url) { [weak self] data, _, _ in
            if let data = data {
                self?.cached[urlString] = data
            }
            self?.lock.unlock()
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
}

