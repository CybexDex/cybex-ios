//
//  HashLockupAssetsTableViewCell.swift
//  cybexMobile
//
//  Created by koofrank on 2019/8/12.
//  Copyright © 2019 Cybex. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

class HashLockupAssetsTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var assetIcon: UIImageView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var amount: UILabel!

    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var to: UILabel!

    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var algorithm: UILabel!
    @IBOutlet weak var hashLabel: UILabel!

    @IBOutlet weak var algorithmView: UIView!
    @IBOutlet weak var hashView: UIView!
    @IBOutlet weak var downRow: UIView!
    @IBOutlet weak var upRow: UIView!

    var cellBag = DisposeBag()
    private(set) var data: Htlc?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.hashLabel.numberOfLines = 0
        toggleExpand(true)
        addGesture()
    }

    func addGesture() {
        [self.upRow.rx.tapGesture(), self.downRow.rx.tapGesture()].forEach { (event) in
            event.when(.recognized).subscribe(onNext: {[weak self] (tap) in
                guard let self = self else {
                    return
                }

                self.toggleExpand(!self.data!.isExpanded)
                self.data!.isExpanded = !self.data!.isExpanded
            }).disposed(by: cellBag)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellBag = DisposeBag()
        self.toggleExpand(!self.data!.isExpanded)
        addGesture()
    }

    func toggleExpand(_ isExpanded: Bool) {
        if !isExpanded {
            downRow.isHidden = true
            upRow.isHidden = false
            algorithmView.isHidden = false
            hashView.isHidden = false
        } else {
            upRow.isHidden = true
            downRow.isHidden = false
            algorithmView.isHidden = true
            hashView.isHidden = true
        }
        (self.viewContainingController() as? HashLockupAssetsViewController)?.tableView.beginUpdates()
        (self.viewContainingController() as? HashLockupAssetsViewController)?.tableView.endUpdates()
    }
    
}

extension HashLockupAssetsTableViewCell {
    func setUpData(data: Htlc) {
        self.data = data

        let url = AppConfiguration.ServerIconsBaseURLString +
            data.transfer.assetId.replacingOccurrences(of: ".", with: "_") +
        "_grey.png"
        self.assetIcon.kf.setImage(with: URL(string: url))

        self.assetName.text = data.transfer.assetId.symbol
        self.amount.text = AssetHelper.getRealAmount(data.transfer.assetId, amount: data.transfer.amount.string).formatCurrency(digitNum: data.transfer.assetId.precision) + " " + data.transfer.assetId.symbol

        self.endTime.text = data.conditions.timeLock.expiration.string(withFormat: "yyyy-MM-dd HH:mm:ss")

        if case let .integer(n) = data.conditions.hashLock.preimageHash[0] {
            self.algorithm.text = HashAlgorithm(value: n)?.rawValue ?? "--"
        }

        self.from.text = data.from
        self.to.text = " " + data.to

        if case let .string(h) = data.conditions.hashLock.preimageHash[1] {
            self.hashLabel.text = h
        }
    }
}
