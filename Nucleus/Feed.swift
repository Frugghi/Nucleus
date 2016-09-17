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
        let components = email.characters.split(maxSplits: 2, omittingEmptySubsequences: true) { " ()".characters.contains($0) }.map(String.init)
        
        self.name = components.last
        self.email = components.first
        self.homePage = nil
    }
    
}

public struct FeedCategory {
    
    public var id: String?
    public var label: String?
    
}

public enum FeedParsingError: Error {
    
    case invalidURL
    case invalidData
    case malformedFeed
    
}

open class Feed {
    
    open let URL: URL
    open var locale: Locale
    
    public init(URL: URL) {
        self.URL = URL
        self.locale = Locale.current
    }
    
    open func load<T: WebFeed>(_ completion: @escaping (T?, Error?) -> Void) {
        let request = URLRequest(url: self.URL)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, FeedParsingError.invalidData)
                }
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                do {
                    let parser = T.createParser()
                    parser.locale = self.locale
                    let result = try parser.parse(data)
                    DispatchQueue.main.async {
                        completion(result, nil)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
                
            }
        }) 
        task.resume()
    }
    
    open class func load<T: WebFeed>(_ URL: String, completion: @escaping (T?, Error?) -> Void) -> Feed? {
        guard let URL = Foundation.URL(string: URL) else {
            DispatchQueue.main.async {
                completion(nil, FeedParsingError.invalidURL)
            }
            return nil
        }
        
        return self.load(URL, completion: completion)
    }
    
    open class func load<T: WebFeed>(_ URL: URL, completion: @escaping (T?, Error?) -> Void) -> Feed {
        let feed = Feed(URL: URL)
        feed.load(completion)
        
        return feed
    }
    
}

open class FeedParser<T: WebFeed> {
    
    open var locale: Locale = Locale.current
    
    open func parse(_ data: Data) throws -> T? {
        return nil
    }
    
}
