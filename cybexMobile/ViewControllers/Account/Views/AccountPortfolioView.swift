//
//  AccountPortfolioView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class AccountPortfolioView: UIView {

    @IBOutlet weak var openPortfolioView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    var data: Any? {
        didSet {
            if let _ = data as? [PortfolioData] {
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }

    enum Event: String {
        case openPortfolio
    }
    fileprivate func setup() {

        let cell = String.init(describing: AccountPortfolioCell.self)
        collectionView.register(UINib.init(nibName: cell, bundle: nil), forCellWithReuseIdentifier: cell)
        openPortfolioView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(openPortfolio))
        openPortfolioView.addGestureRecognizer(gesture)

    }
    @objc func openPortfolio() {
        openPortfolioView.next?.sendEventWith(Event.openPortfolio.rawValue, userinfo: [:])
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
        self.collectionView.collectionViewLayout.invalidateLayout()
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

extension AccountPortfolioView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let balances = data as? [PortfolioData] ?? []
        return balances.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: AccountPortfolioCell.self), for: indexPath) as? AccountPortfolioCell {
            let portfolios = data as? [PortfolioData] ?? []

            cell.setup(portfolios[indexPath.row])
            return cell
        }
        return AccountPortfolioCell()
    }
}
