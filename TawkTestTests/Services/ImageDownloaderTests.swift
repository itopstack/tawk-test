//
//  ImageDownloaderTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import XCTest
@testable import TawkTest

final class ImageDownloaderTests: XCTestCase {
    private var sut: ImageDownloader!
    private var mockSession: MockURLSession!
    private var mockDiskCache: MockURLCache!
    
    override func setUp() {
        super.setUp()
        
        mockSession = MockURLSession()
        mockDiskCache = MockURLCache()
        
        sut = ImageDownloader.shared
        sut.session = mockSession
        sut.cache = mockDiskCache
    }
    
    override func tearDown() {
        super.tearDown()
        
        ImageDownloader.shared.session = URLSession.shared
        ImageDownloader.shared.cache = URLCache.shared
        mockSession = nil
        sut = nil
        mockDiskCache = nil
    }
    
    func test_fetch_fromCached() {
        let urlString = "https://avatars.githubusercontent.com/u/15520417?v=4"
        let data = urlString.data(using: .utf8)
        let exp = expectation(description: "Wait for completion")
        sut.fetch(from: urlString) { _ in }
        mockSession.requestArgs.first?.1(data, nil, nil)
        
        var cachedData: Data?
        sut.fetch(from: urlString) { data in
            cachedData = data
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(cachedData, data)
    }
    
    func test_fetch_fromInvalidURL() {
        let exp = expectation(description: "Wait for completion")
        
        var receivedData: Data?
        sut.fetch(from: "invalid url") { data in
            receivedData = data
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertNil(receivedData)
    }
    
    func test_fetch_fromURLSession() {
        let urlString = "https://avatars.githubusercontent.com/u/15520417?v=4"
        let data = urlString.data(using: .utf8)
        let exp = expectation(description: "Wait for completion")
        
        var receivedData: Data?
        sut.fetch(from: urlString) { data in
            receivedData = data
            exp.fulfill()
        }
        mockSession.requestArgs.first?.1(data, nil, nil)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(receivedData, data)
    }
}

// MARK: - Mock

private final class MockURLSession: Requestable {
    private(set) var requestArgs: [(URL, (Data?, URLResponse?, Error?) -> Void)] = []
    func request(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        requestArgs.append((url, completion))
    }
}

private final class MockURLCache: Cachable {
    func cachedResponse(for request: URLRequest) -> CachedURLResponse? { nil }
}
