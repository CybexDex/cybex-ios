//
//  AnnounceScrollView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/26.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwifterSwift

@IBDesignable
class AnnounceScrollView: CybexBaseView {
    enum Event: String {
        case AnnounceScrollViewDidClicked
    }

    @IBOutlet weak var scrollView: UIScrollView!

    var selectedIndex: Int = 1
    var time: TimeInterval = 5
    fileprivate var timer: Timer?
    fileprivate var topLabel: UILabel!
    fileprivate var bottomLabel: UILabel!
    var animating: Bool = false

    override func setup() {
        super.setup()
        setupUI()
    }

    override var data: Any? {
        didSet {
            if let data = data as? [String], data.count != 0 {
                for subview in scrollView.subviews {
                    if let label = subview as? UILabel {
                        label.removeFromSuperview()
                    }
                }
                timer?.invalidate()
                timer = nil
                selectedIndex = 1
                animating = false
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                self.createSubViews()
            }
        }
    }

    fileprivate func createSubViews() {
        guard let data = self.data as? [String] else { return }
        topLabel = UILabel(frame: self.scrollView.bounds)
        topLabel.font = UIFont.systemFont(ofSize: 12)
        topLabel.theme_textColor = [UIColor.paleGrey.hexString(true), UIColor.darkTwo.hexString(true)]
        topLabel.text = data.first!
        self.scrollView.addSubview(topLabel)

        guard data.count > 1 else { return }
        let label = UILabel(frame: CGRect(x: 0, y: self.topLabel.bottom, width: self.topLabel.width, height: self.topLabel.height))
        label.text = data[1]
        label.font = self.topLabel.font
        label.theme_textColor = [UIColor.paleGrey.hexString(true), UIColor.darkTwo.hexString(true)]
        self.scrollView.addSubview(label)
        bottomLabel = label

        if !animating {
            animating = true
            self.setupSubViewEvent()
        }
    }

    func setupUI() {
        clearBgColor()
        self.scrollView.isUserInteractionEnabled = false
    }

    func setupSubViewEvent() {
        guard let data = self.data as? [String], data.count > 1 else { return }
        let top = self.topLabel!
        let bottom = self.bottomLabel!
        var reverse = false

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {_ in
            UIView.animate(withDuration: 1.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                if !reverse {
                    top.frame = CGRect(x: 0, y: -self.scrollView.bottom, width: self.scrollView.width, height: self.scrollView.height)
                    bottom.frame = self.scrollView.bounds
                } else {
                    bottom.frame = CGRect(x: 0, y: -self.scrollView.bottom, width: self.scrollView.width, height: self.scrollView.height)
                    top.frame = self.scrollView.bounds
                }
            }) { (success) in
                if success {
                    self.selectedIndex += 1
                    if self.selectedIndex >= data.count {
                        self.selectedIndex = 0
                    }

                    if !reverse {
                        top.frame = CGRect(x: 0, y: self.scrollView.bottom, width: self.scrollView.width, height: self.scrollView.height)
                        top.text = data[self.selectedIndex]
                        reverse = true
                    } else {
                        bottom.frame = CGRect(x: 0, y: self.scrollView.bottom, width: self.scrollView.width, height: self.scrollView.height)
                        bottom.text = data[self.selectedIndex]
                        reverse = false
                    }
                }
            }
        }
    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.AnnounceScrollViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self, "index": self.selectedIndex - 1])
    }
}
