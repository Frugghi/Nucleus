//
// The MIT License (MIT)
//
// Copyright (c) 2016 Tommaso Madonia
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public struct RSSFeed: WebFeed {
    
    public fileprivate(set) var attributes: [String : String]
    
    public var version: String { return self.attributes["version"]! }
    public var title: String
    public var URL: URL
    public var description: String
    public var language: String?
    public var copyright: String?
    public var managingEditor: FeedAuthor?
    public var webMaster: FeedAuthor?
    public var publicationDate: Date?
    public var lastBuildDate: Date?
    public var categories: [FeedCategory]
    public var generator: String?
    public var documentation: URL?
    public var timeToLive: Int?
    
    public var items: [RSSItem]
    
    internal init(attributes: [String : String] = [:]) {
        self.attributes = attributes
        self.title = ""
        self.URL = Foundation.URL(string: "www.google.com")!
        self.description = ""
        self.categories = []
        self.items = []
    }
    
    public static func createParser() -> FeedParser<RSSFeed> {
        return RSSParser()
    }
    
}

public struct RSSItem: FeedItem {
    
    public var title: String?
    public var URL: URL?
    public var description: String?
    public var author: FeedAuthor?
    public var categories: [FeedCategory]
    public var medias: [RSSMediaObject]
    public var comments: URL?
    public var id: String?
    public var publicationDate: Date?
    public var source: RSSSource?
    
    internal init() {
        self.categories = []
        self.medias = []
    }
    
}

public struct RSSMediaObject: FeedMediaObject {
    
    public let URL: URL
    public let length: Int
    public let MIMEtype: String
    
    internal init(URL: URL, length: Int, MIMEtype: String) {
        self.URL = URL
        self.length = length
        self.MIMEtype = MIMEtype
    }
    
    internal init(URL: String, length: Int, MIMEtype: String) {
        self.init(URL: Foundation.URL(string: URL)!, length: length, MIMEtype: MIMEtype)
    }
    
}

public struct RSSSource {
    
    public let URL: URL
    public let title: String
    
    internal init(title: String, URL: URL) {
        self.title = title
        self.URL = URL
    }
    
    internal init(title: String, URL: String) {
        self.title = title
        self.URL = Foundation.URL(string: URL)!
    }
    
}

private class RSSParser: FeedParser<RSSFeed>, XMLParserWrapperDelegate {
    
    var feed: RSSFeed?
    var feedItem: RSSItem?
    var element = XMLParsedElement()
    var parseStack = [String]()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = self.locale as Locale!
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return dateFormatter
    }()
    
    override func parse(_ data: Data) throws -> RSSFeed? {
        let parser = XMLParserWrapper(data: data, delegate: self)
        try parser.parse()
        
        guard let feed = self.feed else {
            throw FeedParsingError.malformedFeed
        }
        
        return feed
    }
    
    func didStartXMLElement(_ elementName: String, attributes attributeDict: [String : String]) {
        self.parseStack.append(elementName)
        
        self.element = XMLParsedElement(name: elementName, attributes: attributeDict)
        
        switch elementName.lowercased() {
            
        case "rss":
            self.feed = RSSFeed(attributes: attributeDict)
            
        case "item":
            self.feedItem = RSSItem()
            
        default:
            break
            
        }
    }
    
    func didEndXMLElement(_ elementName: String) {
        self.parseStack.removeLast()
        
        let content = self.element.content
        
        if elementName == "item" {
            self.feed?.items.append(self.feedItem!)
        } else if self.parseStack.last == "channel" {
            switch elementName {
                
            case "title":
                self.feed?.title = content
                
            case "link":
                self.feed?.URL = URL(string: content)!
                
            case "description":
                self.feed?.description = content
                
            case "language":
                self.feed?.language = content
                
            case "copyright":
                self.feed?.copyright = content
                
            case "managingEditor":
                self.feed?.managingEditor = FeedAuthor(content)
                
            case "webMaster":
                self.feed?.webMaster = FeedAuthor(content)
                
            case "pubDate":
                self.feed?.publicationDate = self.dateFormatter.date(from: content)
                
            case "lastBuildDate":
                self.feed?.lastBuildDate = self.dateFormatter.date(from: content)
                
            case "category":
                var category = FeedCategory()
                category.id = self.element.attributes["domain"]
                category.label = content
                
                self.feed?.categories.append(category)
                
            case "generator":
                self.feed?.generator = content
                
            case "docs":
                self.feed?.documentation = URL(string: content)
                
            case "ttl":
                self.feed?.timeToLive = Int(content)
                
            default:
                break
                
            }
        } else if self.parseStack.last == "item" {
            switch elementName {
                
            case "title":
                self.feedItem?.title = content
                
            case "link":
                self.feedItem?.URL = URL(string: content)
                
            case "description":
                self.feedItem?.description = content
                
            case "author":
                self.feedItem?.author = FeedAuthor(content)
                
            case "category":
                var category = FeedCategory()
                category.id = self.element.attributes["domain"]
                category.label = content
                
                self.feedItem?.categories.append(category)
                
            case "comments":
                self.feedItem?.comments = URL(string: content)
                
            case "enclosure":
                let URL = self.element.attributes["url"]!
                let length = Int(self.element.attributes["length"]!)!
                let MIMEtype = self.element.attributes["type"]!
                let mediaObject = RSSMediaObject(URL: URL, length: length, MIMEtype: MIMEtype)
                
                self.feedItem?.medias.append(mediaObject)
                
            case "guid":
                self.feedItem?.id = content
                
            case "pubDate":
                self.feedItem?.publicationDate = self.dateFormatter.date(from: content)
                
            case "source":
                self.feedItem?.source = RSSSource(title: content, URL: self.element.attributes["url"]!)
                
            default:
                break
                
            }
        }
    }
    
    func foundCharacters(_ string: String) {
        self.element.append(string)
    }
    
}
