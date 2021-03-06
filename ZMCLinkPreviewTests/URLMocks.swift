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

import ZMCLinkPreview

class MockURLSessionDataTask: URLSessionDataTaskType {
    
    var taskIdentifier = 0
    var resumeCallCount = 0
    var cancelCallCount = 0
    var mockOriginalRequest: NSURLRequest? = nil
    
    var originalRequest: NSURLRequest? {
        return mockOriginalRequest
    }
    
    func resume() {
        resumeCallCount += 1
    }
    
    func cancel() {
        cancelCallCount += 1
    }
}

class MockURLSession: URLSessionType {
    
    var dataTaskWithURLCallCount = 0
    var dataTaskWithURLParameters = [NSURL]()
    var dataTaskWithURLClosureCallCount = 0
    var dataTaskWithURLClosureCompletions = [DataTaskCompletion]()
    var mockDataTask: MockURLSessionDataTask? = nil
    var dataTaskGenerator: ((NSURL, DataTaskCompletion) -> URLSessionDataTaskType)? = nil
    
    func dataTaskWithURL(url: NSURL) -> URLSessionDataTaskType {
        dataTaskWithURLCallCount += 1
        dataTaskWithURLParameters.append(url)
        return mockDataTask!
    }
    
    func dataTaskWithURL(url: NSURL, completionHandler: DataTaskCompletion) -> URLSessionDataTaskType {
        dataTaskWithURLClosureCallCount += 1
        dataTaskWithURLClosureCompletions.append(completionHandler)
        if let generator = dataTaskGenerator {
            return generator(url, completionHandler)
        } else {
            completionHandler(nil, nil, nil)
            return mockDataTask!
        }
    }
}
