//
//  UnitTestcaseRowType.swift
//  watchOS Example Extension
//
//  Created by Apollo Zhu on 12/27/17.
//
//  Copyright (c) 2017 EyreFree <eyrefree@eyrefree.org>
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

import WatchKit

extension String {
    static let passed = "Passed"
    static let testing = "Testing..."
}

class UnitTestcaseRowType: NSObject {
    @IBOutlet private var testcaseNameLabel: WKInterfaceLabel? {
        didSet {
            testcaseNameLabel?.setText(test?.name)
        }
    }
    @IBOutlet private var testcaseStatusLabel: WKInterfaceLabel? {
        didSet {
            testcaseStatusLabel?.setText(status)
        }
    }
    public var test: (name: String, testcase: Testcase)? {
        didSet {
            testcaseNameLabel?.setText(test?.name)
            status = .testing
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.status = self?.test?.testcase() ?? .passed
            }
        }
    }
    private var status: String = .testing {
        didSet {
            testcaseStatusLabel?.setText(status)
            switch status {
            case .testing:
                testcaseStatusLabel?.setTextColor(.white)
            case .passed:
                testcaseStatusLabel?.setTextColor(.green)
            default:
                testcaseStatusLabel?.setTextColor(.red)
            }
        }
    }
}
