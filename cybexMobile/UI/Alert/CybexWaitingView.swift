//
//  CybexWaitingView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

protocol CybexWaitingProtocol {
    func waitingEnsureAction(sender: CybexWaitingView)
}

@IBDesignable
class CybexWaitingView: BaseView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var ensureBtn: UIButton!
    
    var delegate: CybexWaitingProtocol?
    var angle: CGFloat = 1.0
    var timer: Timer?
    var time: Int? {
        didSet{
            if self.timer == nil {
                ensureBtn.setTitle(String(describing: self.time!), for: .normal)
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
                self.timer?.fire()
                self.iconTransformAnimation()
               
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        setupUI()
    }
    
    func setupUI() {
        self.titleLabel.textAlignment = .center
        self.contentLabel.textAlignment = .center
        ensureBtn.isEnabled = false
        ensureBtn.addTarget(self, action: #selector(ensureBtnAction), for: .touchUpInside)
    }
    
    func iconTransformAnimation() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.01)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(endAnimation))
        self.icon.transform = CGAffineTransform(rotationAngle: angle * CGFloat(Double.pi / 180.0))
        UIView.commitAnimations()
    }
}

extension CybexWaitingView {
    @objc func timerAction() {
        if self.time! <= 0 {
            self.timer?.invalidate()
            ensureBtn.setTitle(R.string.localizable.alert_ensure.key.localized(), for: .normal)
            ensureBtn.isEnabled = true
            self.delegate?.waitingEnsureAction(sender: self)
        }
        else {
            self.time = self.time! - 1
            ensureBtn.setTitle(String(describing: self.time!), for: .normal)
        }
    }
    
    @objc func endAnimation() {
        self.angle += 10
        self.iconTransformAnimation()
    }
    
    @objc func ensureBtnAction() {
        self.delegate?.waitingEnsureAction(sender: self)
    }
}

extension CybexWaitingView: Views {
    var content: Any? {
        get {
            return self.data
        }
        set {
            self.data = content
        }
    }
}
