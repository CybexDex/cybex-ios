//
//  CybexTextView.swift
//  Demo
//
//  Created by DKM on 2018/6/6.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import TinyConstraints
import SwiftTheme
import RxGesture

protocol CybexTextViewDelegate {
    func returnPassword(_ password: String, sender: CybexTextView)
    func clickCancle(_ sender: CybexTextView)
    func returnEnsureAction()
    func returnEnsureImageAction()
    func didClickedRightAction()
}

class CybexTextView: UIView {

    enum TextViewType: Int {
        case normal
        case time
        case `switch`
    }

    var middleView: (UIView&Views)? {
        didSet {
            contentView.addSubview(middleView!)
            middleView?.leading(to: contentView, offset: 20)
            middleView?.trailing(to: contentView, offset: -20)
            middleView?.top(to: contentView, offset: 25)
            middleView?.bottom(to: contentView, offset: 0)
        }
    }

    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    var delegate: CybexTextViewDelegate?
    var data: Any? {
        didSet {
            self.middleView?.content  = data
            self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
        }
    }

    var viewType: TextViewType? {
        didSet {

        }
    }

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var hSeparateView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rightTitle: UILabel!

    @IBOutlet weak var cancle: UIButton!
    @IBOutlet weak var ensure: UIButton!

    @IBOutlet weak var contentView: UIView!
    @IBAction func cancleClick(_ sender: Any) {
        self.delegate?.clickCancle(self)
    }

    @IBAction func ensureClick(_ sender: Any) {
        if let tf = self.middleView as? CybexPasswordView {
            self.delegate?.returnPassword(tf.textField.text!, sender: self)
        } else {
            if titleImageView.isHidden == true {
                self.delegate?.returnEnsureAction()
            } else {
                self.delegate?.returnEnsureImageAction()
            }
        }
    }

    func setup() {
        self.cancle.setTitleColor(ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo, for: .normal)

        self.rightTitle.rx.tapGesture().asObservable().when(GestureRecognizerState.recognized).subscribe(onNext: { [weak self](tap) in
            guard let self = self else {
                return
            }
            self.delegate?.didClickedRightAction()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }

    @objc fileprivate func updateHeight() {
        self.contentViewHeight.constant = middleView!.height + 25

        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
        setup()
    }

    func loadFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.layer.cornerRadius = 4.0
        view.clipsToBounds = true
        addSubview(view)

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

extension CybexTextView: Views {
    var content: Any? {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }
}
