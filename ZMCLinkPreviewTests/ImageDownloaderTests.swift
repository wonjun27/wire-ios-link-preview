// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import XCTest
@testable import ZMCLinkPreview

class ImageDownloaderTests: XCTestCase {
    
    var sut: ImageDownloader!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = ImageDownloader(resultsQueue: .mainQueue(), workerQueue:.mainQueue(), session: mockSession)
    }
    
    func testThatItCreatesADataTaskForTheImageURL() {
        // given
        let expectation = expectationWithDescription("It should call the completion handler")
        let url = NSURL(string: "www.example.com")!
        let mockTask = MockURLSessionDataTask()
        mockSession.mockDataTask = mockTask
        
        // when
        sut.downloadImage(fromURL: url) { _ in
            expectation.fulfill()
        }
        
        // then
        waitForExpectationsWithTimeout(0.2, handler: nil)
        XCTAssertEqual(mockSession.dataTaskWithURLClosureCallCount, 1)
        XCTAssertEqual(mockTask.resumeCallCount, 1)
    }
    
    func testThatitCallsTheCompletionOnTheResultsQueue() {
        let expectation = expectationWithDescription("It should call the completion handler")
        let url = NSURL(string: "www.example.com")!
        mockSession.mockDataTask = MockURLSessionDataTask()

        let queue = NSOperationQueue()
        sut = ImageDownloader(resultsQueue: queue, session: mockSession)
        
        // when
        sut.downloadImage(fromURL: url) { _ in
            XCTAssertEqual(NSOperationQueue.currentQueue(), queue)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testThatItCreatesAndResumesADataTaskForAllURLs() {
        // given
        let expectation = expectationWithDescription("It should call the completion handler")
        let urls = [
            NSURL(string: "www.example.com/1")!,
            NSURL(string: "www.example.com/2")!,
            NSURL(string: "www.example.com/3")!,
            NSURL(string: "www.example.com/4")!
        ]
        
        let mockTask = MockURLSessionDataTask()
        
        var callCount = 0
        mockSession.dataTaskGenerator = { _, completion in
            completion(nil, nil, nil)
            callCount += 1
            if callCount == 4 {
                expectation.fulfill()
            }
            return mockTask
        }
        
        // when
        sut.downloadImages(fromURLs: urls) { _ in }
        
        // then
        waitForExpectationsWithTimeout(0.2, handler: nil)
        XCTAssertEqual(mockSession.dataTaskWithURLClosureCallCount, 4)
        XCTAssertEqual(mockTask.resumeCallCount, 4)
    }
    
    func testThatItDoesReturnTheDataIfTheResponseHeaderContainsContentTypeImage_JPEG() {
        assertThatItReturnsTheImageData(true, withHeaderFields: ["Content-Type": "image/jpeg"])
    }
    
    func testThatItDoesReturnTheDataIfTheResponseHeaderContainsContentTypeImage_JPG() {
        assertThatItReturnsTheImageData(true, withHeaderFields: ["Content-Type": "image/jpg"])
    }
    
    func testThatItDoesReturnTheDataIfTheResponseHeaderContainsContentTypeImage_PNG() {
        assertThatItReturnsTheImageData(true, withHeaderFields: ["Content-Type": "image/png"])
    }
    
    func testThatItDoesReturnTheDataIfTheResponseHeaderContainsContentTypeImage_GIF() {
        assertThatItReturnsTheImageData(true, withHeaderFields: ["content-type": "image/gif"])
    }
    
    func testThatItDoesNotReturnTheDataInTheCompletionIfTheResponseHeaderDoesNotContainContentTypeImage() {
        assertThatItReturnsTheImageData(false, withHeaderFields: ["Content-Type": "text/html"])
    }
    
    func testThatItDoesNotReturnTheDataInTheCompletionIfTheResponseHeaderDoesNotContainContentTypeImage_lowercase() {
        assertThatItReturnsTheImageData(false, withHeaderFields: ["content-type": "text/html"])
    }
    
    func assertThatItReturnsTheImageData(shouldReturn: Bool, withHeaderFields headers: [String: String], line: UInt = #line) {
        // given
        let expectation = expectationWithDescription("It should call the completion handler")
        let url = NSURL(string: "www.example.com")!
        
        let data = "test data".utf8Data
        let response = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: headers)
        
        mockSession.dataTaskGenerator = { url, completion in
            completion(data, response, nil)
            return MockURLSessionDataTask()
        }
        
        var result: NSData? = nil
        
        // when
        sut.downloadImage(fromURL: url) {
            result = $0
            expectation.fulfill()
        }
        
        // then
        waitForExpectationsWithTimeout(2, handler: nil)
        if shouldReturn {
            XCTAssertEqual(result, data, line: line)
        } else {
            XCTAssertNil(result, line: line)
        }
    }
}
