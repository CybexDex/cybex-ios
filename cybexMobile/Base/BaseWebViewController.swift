//
//  BaseWebViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import WebKit
import TinyConstraints

class BaseWebViewController: BaseViewController {

    public var url: URL? {
        didSet {
            guard let url = url else { return }
            if let fragment = url.fragment {
                let max = UInt32.max - 1
                let random = Int.random(between: 1, and: Int(max))
                let chUrl = URL(string: url.absoluteString.replacingOccurrences(of: "#\(fragment)", with: "#\(random)"))!
                webView.load(URLRequest.init(url: chUrl))
            } else {
                webView.load(URLRequest.init(url: url))
            }
        }
    }

    lazy var webView: WKWebView = {
        let view = WKWebView.init()
        view.clipsToBounds = true
        view.scrollView.clipsToBounds = true
        view.isOpaque = false
        view.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.edgesToSuperview(insets: .zero, priority: .required, isActive: true, usingSafeArea: true)

        if let url = url {
            webView.load(URLRequest.init(url: url))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func clearCahce() {
        guard let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]) as? Set<String> else {
            return
        }
        let date = NSDate(timeIntervalSince1970: 0)

        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date as Date, completionHandler: { })
    }
}

extension BaseWebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.startLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        endLoading()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error._code == NSURLErrorCancelled {
            return
        } else {
            endLoading()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        endLoading()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
