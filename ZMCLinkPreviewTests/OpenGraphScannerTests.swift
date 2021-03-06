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

class OpenGraphScannerTests: XCTestCase {
    
    func testThatItCanParseCorrectlyStrippedSampleData_Twitter() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.twitterData())
    }
    
    func testThatItCanParseCorrectlyStrippedSampleData_TwitterWithImages() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.twitterDataWithImages())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_Verge() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.vergeData())
    }
    
    func testThatItCanParseCorrectlyStrippedSampleData_Foursquare() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.foursqaureData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_YouTube() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.youtubeData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_Guardian() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.guardianData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_Imstagram() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.instagramData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_Vimeo() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.vimeoData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_NYTimes() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.nytimesData())
    }
    
    func testThatItCanParseCorrectlyStrippedSampleData_WashingtonPost() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.washingtonPostData())
    }
    
    func testThatItCanParseCorrectlyStrippedSampleData_Wire() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.wireData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_Polygon() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.polygonData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_iTunes() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.iTunesData())
    }

    func testThatItCanParseCorrectlyStrippedSampleData_iTunesWithoutTitle() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.iTunesDataWithoutTitle())
    }
    
    func testThatItCanParseCorrectlyStrippedSampleData_yahooSports() {
        assertThatItParsesSampleDataCorrectly(OpenGraphMockDataProvider.yahooSports())
    }

    func assertThatItParsesSampleDataCorrectly(mockData: OpenGraphMockData, line: UInt = #line) {
        // given
        var receivedData: OpenGraphData?
        let head = mockData.head

        // when
        let sut = OpenGraphScanner(head, url: NSURL(string: mockData.urlString)!) { receivedData = $0 }
        sut.parse()

        // then
        XCTAssertNotNil(receivedData, line: line)
        XCTAssertEqual(mockData.expected, receivedData, line: line)
    }
    
}
