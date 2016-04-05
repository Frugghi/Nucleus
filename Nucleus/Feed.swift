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

public protocol WebFeed {
    
    var attributes: [String : String] { get }
    
    var title: String { get }
    
    static func createParser() -> FeedParser<Self>
    
}

public protocol FeedItem {
    
}

public protocol FeedMediaObject {
    
}

public struct FeedAuthor {
    
    public let name: String?
    public let email: String?
    public let homePage: String?
    
    internal init(name: String?, email: String?, homePage: String?) {
        self.name = name
        self.email = email
        self.homePage = homePage
    }
    
    internal init(_ email: String) {
        let components = email.characters.split(2, allowEmptySlices: false) { " ()".characters.contains($0) }.map(String.init)
        
        self.name = components.last
        self.email = components.first
        self.homePage = nil
    }
    
}

public struct FeedCategory {
    
    public var id: String?
    public var label: String?
    
}

public enum FeedParsingError: ErrorType {
    
    case InvalidURL
    case InvalidData
    case MalformedFeed
    
}

public class Feed {
    
    public let URL: NSURL
    public var locale: NSLocale
    
    public init(URL: NSURL) {
        self.URL = URL
        self.locale = NSLocale.currentLocale()
    }
    
    public func load<T: WebFeed>(completion: (T?, ErrorType?) -> Void) {
        let request = NSURLRequest(URL: self.URL)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(nil, FeedParsingError.InvalidData)
                }
                return
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                do {
                    let parser = T.createParser()
                    parser.locale = self.locale
                    let result = try parser.parse(data)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(result, nil)
                    }
                } catch let error {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil, error)
                    }
                }
                
            }
        }
        task.resume()
    }
    
    public class func load<T: WebFeed>(URL: String, completion: (T?, ErrorType?) -> Void) -> Feed? {
        guard let URL = NSURL(string: URL) else {
            dispatch_async(dispatch_get_main_queue()) {
                completion(nil, FeedParsingError.InvalidURL)
            }
            return nil
        }
        
        return self.load(URL, completion: completion)
    }
    
    public class func load<T: WebFeed>(URL: NSURL, completion: (T?, ErrorType?) -> Void) -> Feed {
        let feed = Feed(URL: URL)
        feed.load(completion)
        
        return feed
    }
    
}

public class FeedParser<T: WebFeed> {
    
    public var locale: NSLocale = NSLocale.currentLocale()
    
    public func parse(data: NSData) throws -> T? {
        return nil
    }
    
}
