//
//  PairListHorizantalView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwifterSwift

@IBDesignable
class PairListHorizantalView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!

    var pairData: [HomeBucket] = []
    var curIndex: Int?

    var data: Any? {
        didSet {
            guard let datas = data as? [Any], let curIndex = datas[0] as? Int, let markets = datas[1] as? [HomeBucket], markets.count > 0 else { return }

            self.pairData = markets
            self.curIndex = curIndex

            self.collectionView.reloadData()
            self.collectionView.selectItem(at: IndexPath(item: self.curIndex ?? 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    override func didMoveToSuperview() {
        SwifterSwift.delay(milliseconds: 100) {
            if (self.curIndex != nil) {
                self.collectionView.selectItem(at: IndexPath(item: self.curIndex ?? 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            }
        }

    }

    fileprivate func setup() {
        collectionView.register(UINib(nibName: String(describing: PairCardCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: PairCardCell.self))
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

extension PairListHorizantalView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pairData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PairCardCell.self), for: indexPath) as? PairCardCell {
            let data = pairData[indexPath.item]
            cell.setup(data, indexPath: indexPath)
            cell.isSelected = indexPath.item == self.curIndex

            return cell
        }
        return PairCardCell()
    }
}
