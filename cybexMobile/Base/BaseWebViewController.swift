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
import SwiftTheme
import SwifterSwift

class BaseWebViewController: BaseViewController {
    let progressView = UIProgressView(progressViewStyle: .default)
    private var estimatedProgressObserver: NSKeyValueObservation?

    public var url: URL? {
        didSet {
            guard let url = url else { return }
            if let fragment = url.fragment {
                let max = UInt32.max - 1
                let random = Int.random(in: 1...Int(max))
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
        setupProgressView()
        setupEstimatedProgressObserver()

        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.edgesToSuperview(insets: .zero, priority: .required, isActive: true, usingSafeArea: true)

        if let url = url {
            webView.load(URLRequest.init(url: url))
        }
    }

    private func setupProgressView() {
        guard let navigationBar = navigationController?.navigationBar else { return }

        progressView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(progressView)

        progressView.isHidden = true
        progressView.progressTintColor = UIColor.pastelOrange
        let color = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
        progressView.trackTintColor = color

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),

            progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0)
            ])
    }

    deinit {
        progressView.removeFromSuperview()
    }

    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension BaseWebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if progressView.isHidden {
            // Make sure our animation is visible.
            progressView.isHidden = false
        }

        UIView.animate(withDuration: 0.33,
                       animations: {
                        self.progressView.alpha = 1.0
        })
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.33,
                       animations: {
                        self.progressView.alpha = 0.0
        },
                       completion: { isFinished in
                        // Update `isHidden` flag accordingly:
                        //  - set to `true` in case animation was completly finished.
                        //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                        self.progressView.isHidden = isFinished
        })
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error._code == NSURLErrorCancelled {
            return
        } else {
//            endLoading()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        endLoading()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
