//
//  TransferContentView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class TransferContentView: UIView {

    enum Event: String {
        case transferMemo
    }

    @IBOutlet weak var addressView: TransferLineView!
    @IBOutlet weak var timeView: TransferLineView!
    @IBOutlet weak var feeView: TransferLineView!
    @IBOutlet weak var vestingPeriodView: TransferLineView!
    @IBOutlet weak var memoView: TransferLineView!

    var data: Any? {
        didSet {
            if let data = data as? TransferRecordViewModel {
                fillContent(data)
                updateHeight()
            }
        }
    }

    var contentText: String? {
        didSet {
            if let text = contentText {
                self.memoView.contentLocali = text
                updateHeight()
            }
        }
    }

    func fillContent(_ data: TransferRecordViewModel) {
        addressView.nameLocali = data.isSend ? R.string.localizable.transfer_detail_send_address.key.localized() : R.string.localizable.transfer_detail_income_address.key.localized()
        addressView.contentLocali = data.name
        timeView.contentLocali = data.time

        if data.vestingPeriod == "0" {
            vestingPeriodView.contentLocali = R.string.localizable.transfer_detail_nodata.key.localized()
        } else {
            vestingPeriodView.contentLocali = transferTimeType(Int(data.vestingPeriod)!)
        }
        if data.memo.isEmpty {
            memoView.contentLocali = R.string.localizable.transfer_detail_nodata.key.localized()
        } else {
            memoView.contentLocali = R.string.localizable.transfer_detail_click.key.localized()
            memoView.content.textColor = UIColor.pastelOrange
            memoView.isUserInteractionEnabled = true
            memoView.content.rx.tapGesture().when(.recognized).asObservable().subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.next?.sendEventWith(Event.transferMemo.rawValue, userinfo: ["memoView": ""])
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        }

        if let feeInfo = data.fee, let assetInfo = appData.assetInfo[feeInfo.assetId] {
            let realAmount = AssetHelper.getRealAmount(feeInfo.assetId, amount: feeInfo.amount)
            var amountStr = realAmount.string(digits: assetInfo.precision, roundingMode: .down) + " "
            amountStr.append(assetInfo.symbol.filterSystemPrefix)

            feeView.contentLocali = amountStr
        }
    }

    func setup() {
        addressView.content.textContainer.maximumNumberOfLines = 1
        addressView.content.textContainer.lineBreakMode = .byTruncatingMiddle
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
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
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func loadFromXIB() {
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
