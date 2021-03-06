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


import Foundation

public struct OpenGraphData {
    let title: String
    let type: String
    let url: String
    let imageUrls: [String]

    let siteName: OpenGraphSiteName
    let siteNameString: String?
    let description: String?
    let userGeneratedImage: Bool
    
    var foursquareMetaData: FoursquareMetaData?
    
    init(title: String, type: String?, url: String, imageUrls: [String], siteName: String? = nil, description: String? = nil, userGeneratedImage: Bool = false) {
        self.title = title
        self.type = type ?? OpenGraphTypeType.Website.rawValue
        self.url = url
        self.imageUrls = imageUrls
        self.siteNameString = siteName
        self.siteName = siteName.map { OpenGraphSiteName(string: $0) ?? .Other } ?? .Other
        self.description = description
        self.userGeneratedImage = userGeneratedImage
    }
}

public struct FoursquareMetaData {
    let latitude: Float
    let longitude: Float
    
    init(latitude: Float, longitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init?(propertyMapping mapping: OpenGraphData.PropertyMapping) {
        guard let latitude = mapping[.LatitudeFSQ].flatMap(Float.init), longitude = mapping[.LongitudeFSQ].flatMap(Float.init) else { return nil }
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension OpenGraphData {
    
    typealias PropertyMapping = [OpenGraphPropertyType: String]
    
    init?(propertyMapping mapping: PropertyMapping, images: [String]) {
        guard let title = mapping[.Title],
            url = mapping[.Url] else { return nil }
     
        self.init(
            title: title,
            type: mapping[.Type],
            url: url,
            imageUrls: images,
            siteName: mapping[.SiteName],
            description: mapping[.Description],
            userGeneratedImage: mapping[.UserGeneratedImage] == "true"
        )
        
        foursquareMetaData = FoursquareMetaData(propertyMapping: mapping)
    }
    
}

extension OpenGraphData: Equatable {}

public func ==(lhs: OpenGraphData, rhs: OpenGraphData) -> Bool {
    return lhs.title == rhs.title && lhs.type == rhs.type &&
        lhs.url == rhs.url && lhs.imageUrls == rhs.imageUrls &&
        lhs.siteName == rhs.siteName && lhs.description == rhs.description &&
        lhs.siteNameString == rhs.siteNameString && lhs.userGeneratedImage == rhs.userGeneratedImage &&
        lhs.foursquareMetaData == rhs.foursquareMetaData
}

extension FoursquareMetaData: Equatable {}

public func ==(lhs: FoursquareMetaData, rhs: FoursquareMetaData) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension Article {
    public convenience init(openGraphData: OpenGraphData, originalURLString: String, offset: Int) {
        self.init(originalURLString: originalURLString, permamentURLString: openGraphData.url, offset: offset)
        title = openGraphData.title
        summary = openGraphData.description
        guard let imageURL = openGraphData.imageUrls.flatMap ({ NSURL(string: $0) }).first else { return }
        imageURLs.append(imageURL)
    }
}

extension FoursquareLocation {
    public convenience init?(openGraphData: OpenGraphData, originalURLString: String, offset: Int) {
        guard openGraphData.type  == OpenGraphTypeType.Foursqaure.rawValue && openGraphData.siteName == .Foursquare else { return nil }
        
        self.init(originalURLString: originalURLString, permamentURLString: openGraphData.url, offset: offset)
        title = openGraphData.title
        subtitle = openGraphData.description
        longitude = openGraphData.foursquareMetaData?.longitude
        latitude = openGraphData.foursquareMetaData?.latitude
        guard let imageURL = openGraphData.imageUrls.flatMap ({ NSURL(string: $0) }).first else { return }
        imageURLs.append(imageURL)
    }
}

extension InstagramPicture {
    public convenience init?(openGraphData: OpenGraphData, originalURLString: String, offset: Int) {
        guard openGraphData.type == OpenGraphTypeType.Instagram.rawValue && openGraphData.siteName == .Instagram else { return nil }
        self.init(originalURLString: originalURLString, permamentURLString: openGraphData.url, offset: offset)
        title = openGraphData.title
        subtitle = openGraphData.description
        guard let imageURL = openGraphData.imageUrls.flatMap ({ NSURL(string: $0) }).first else { return }
        imageURLs.append(imageURL)
    }
}

extension TwitterStatus {

    public convenience init?(openGraphData: OpenGraphData, originalURLString: String, offset: Int) {
        guard openGraphData.type == OpenGraphTypeType.Article.rawValue && openGraphData.siteName == .Twitter else { return nil }
        
        self.init(originalURLString: originalURLString, permamentURLString: openGraphData.url, offset: offset)
        message = openGraphData.description
        author = openGraphData.title.stringByReplacingOccurrencesOfString(" on Twitter", withString: "", options: [.AnchoredSearch, .BackwardsSearch], range: nil)
        imageURLs = openGraphData.userGeneratedImage ? openGraphData.imageUrls.flatMap { NSURL(string: $0) } : []
    }
}

extension OpenGraphData  {
    
    func linkPreview(originalURLString: String, offset: Int) -> LinkPreview {
        return TwitterStatus(openGraphData: self, originalURLString: originalURLString, offset: offset) ??
            Article(openGraphData: self, originalURLString: originalURLString, offset: offset)
    }
    
}
