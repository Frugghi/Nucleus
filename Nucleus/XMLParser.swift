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

internal protocol XMLParser: class {
    
    func didStartXMLElement(elementName: String, attributes attributeDict: [String : String])
    func didEndXMLElement(elementName: String)
    func foundCharacters(string: String)
    
}

internal class XMLParserWrapper<T: XMLParser>: NSObject, NSXMLParserDelegate {
    
    let parser: NSXMLParser
    weak var delegate: T?
    
    init(data: NSData, delegate: T) {
        self.parser = NSXMLParser(data: data)
        self.delegate = delegate
    }
    
    func parse() throws {
        self.parser.delegate = self
        self.parser.shouldResolveExternalEntities = false
        self.parser.parse()
        
        if let error = self.parser.parserError {
            throw error
        }
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.delegate?.didStartXMLElement(elementName, attributes: attributeDict)
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.delegate?.didEndXMLElement(elementName)
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        self.delegate?.foundCharacters(string)
    }
    
}

internal struct XMLParsedElement {
    
    var attributes: [String : String]
    var name: String
    var content: String
    
    init() {
        self.name = ""
        self.attributes = [:]
        self.content = ""
    }
    
    init(name: String, attributes: [String : String]) {
        self.name = name
        self.attributes = attributes
        self.content = ""
    }
    
}

internal func +=(inout lhs: XMLParsedElement, rhs: String) -> XMLParsedElement {
    lhs.content += rhs
    return lhs
}