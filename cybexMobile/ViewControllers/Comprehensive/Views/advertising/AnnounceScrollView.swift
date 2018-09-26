//
//  AnnounceScrollView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/26.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class AnnounceScrollView: CybexBaseView {
    enum Event:String {
        case AnnounceScrollViewDidClicked
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var selectedIndex: Int = 0
    var time: TimeInterval = 3
    fileprivate var timer: Timer!
    fileprivate var topLabel: UILabel!
    fileprivate var bottomLabel: UILabel!
    
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    override var data: Any? {
        didSet {
            if let data = data as? [String], data.count != 0 {
                self.createSubViews()
            }
        }
    }
    
    fileprivate func createSubViews() {
        guard let data = self.data as? [String] else { return }
        self.scrollView.isUserInteractionEnabled = false
        topLabel = UILabel(frame: self.scrollView.bounds)
        topLabel.font = UIFont.systemFont(ofSize: 12)
        topLabel.theme_textColor = [UIColor.paleGrey.hexString(true), UIColor.darkTwo.hexString(true)]
        topLabel.text = data.first!
        self.scrollView.addSubview(topLabel)
        startTimer()
    }
    
    fileprivate func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: self.time, target: self, selector: #selector(scrollLabelAction), userInfo: nil, repeats: true)
        self.timer.fire()
    }
    
    func setupUI() {
        clearBgColor()
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.AnnounceScrollViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self ,"index": self.selectedIndex])
    }
    deinit {
        self.timer.invalidate()
        self.timer = nil
    }
}

extension AnnounceScrollView {
    @objc func scrollLabelAction() {
        guard let data = self.data as? [String] else { return }
        if selectedIndex < data.count - 1 {
            selectedIndex = selectedIndex + 1
        }
        else {
            selectedIndex = 0
        }
        let label = UILabel(frame: CGRect(x: 0, y: self.topLabel.bottom, width: self.topLabel.width, height: self.topLabel.height))
        label.text = data[selectedIndex]
        label.font = topLabel.font
        label.theme_textColor = [UIColor.paleGrey.hexString(true), UIColor.darkTwo.hexString(true)]
        self.scrollView.addSubview(label)
        let point = self.scrollView.contentOffset
        
        UIView.animate(withDuration: 1.5, animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: point.y + self.scrollView.height)
        }) { (success) in
            self.topLabel = label
            label.removeSubviews()
        }
    }
}
