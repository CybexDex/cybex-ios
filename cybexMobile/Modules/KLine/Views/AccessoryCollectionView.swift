//
//  AccessoryCollectionView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class AccessoryCollectionView: UIView {
    enum Event: String {
        case indicatorClicked = "indicatorClicked"
    }

    @IBOutlet weak var title: UILabel!

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                title.textColor = #colorLiteral(red: 1, green: 0.6386402845, blue: 0.3285836577, alpha: 1)
            } else {
                title.textColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)
            }
        }

    }

    var data: Any? {
        didSet {
            guard let indicator = data as? Indicator else { return }

            self.title.text = indicator.rawValue
        }
    }

    fileprivate func setup() {
        self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }

            self.next?.sendEventWith(Event.indicatorClicked.rawValue, userinfo: ["indicator": self.data ?? []])

        }).disposed(by: disposeBag)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
