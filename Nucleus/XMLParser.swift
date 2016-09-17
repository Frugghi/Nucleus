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

internal protocol XMLParserWrapperDelegate: class {
    
    func didStartXMLElement(_ elementName: String, attributes attributeDict: [String : String])
    func didEndXMLElement(_ elementName: String)
    func foundCharacters(_ string: String)
    
}

internal class XMLParserWrapper<T: XMLParserWrapperDelegate>: NSObject, XMLParserDelegate {
    
    let parser: XMLParser
    weak var delegate: T?
    
    init(data: Data, delegate: T) {
        self.parser = XMLParser(data: data)
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
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print("Start: \(elementName)")
        self.delegate?.didStartXMLElement(elementName, attributes: attributeDict)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("End: \(elementName)")
        self.delegate?.didEndXMLElement(elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
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
    
    mutating func append(_ content: String) {
        self.content += content
    }
    
}

internal func +=(lhs: inout XMLParsedElement, rhs: String) -> XMLParsedElement {
    lhs.content += rhs
    return lhs
}
