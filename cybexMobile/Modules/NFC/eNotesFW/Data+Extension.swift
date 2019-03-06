//
//  Data+Extension.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/28.
//  Copyright © 2018 eNotes. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Data {
    
    public func subdata(in range: CountableClosedRange<Data.Index>) -> Data
    {
        return self.subdata(in: range.lowerBound..<range.upperBound + 1)
    }
}

extension Data {
    
    public init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
    }
    
    public var bytes: Array<UInt8> {
        return Array(self)
    }
    
//    public func toHexString() -> String {
//        return bytes.toHexString()
//    }
}

extension Data {
    public func toBase64String() -> String {
        return self.base64EncodedString(options: .endLineWithLineFeed)
    }
}
