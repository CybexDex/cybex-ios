//
//  AccountTableHeadView.swift
//  cybexMobile
//
//  Created by zhusongyu on 2018/7/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class AccountTableHeadView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var coinAge: UILabel!
    @IBOutlet weak var coinAgeIcon: UIImageView!
    @IBOutlet weak var coinAgeContainer: UIStackView!

    enum Event: String {
        case login
        case coinAgeDesc
    }

    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }

    func setup() {
        setupEvent()
        //    updateHeight()
    }

    func setupEvent() {
        titleLabel.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _  in
            guard let self = self else { return}
            self.next?.sendEventWith(Event.login.rawValue, userinfo: [:])
        }).disposed(by: disposeBag)

        coinAgeIcon.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _  in
            guard let self = self else { return}
            self.next?.sendEventWith(Event.coinAgeDesc.rawValue, userinfo: [:])
        }).disposed(by: disposeBag)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXIB()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXIB()
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    private func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let view = self.subviews.last?.subviews.last
        return (view?.frame.origin.y)! + (view?.frame.size.height)!
    }

    func loadXIB() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib.init(nibName: String.init(describing: type(of: self)), bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
