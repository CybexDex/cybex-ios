//
//  AccessoryHorizentalView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class AccessoryHorizentalView: UIView {
  @IBOutlet weak var collectionView: UICollectionView!

  var data: Any? {
    didSet {
      guard let cur_indicator = data as? indicator else { return }

      self.collectionView.reloadData()
      self.collectionView.selectItem(at: IndexPath(item: indicator.all.index(of: cur_indicator) ?? 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
  }
  
  
  fileprivate func setup() {
    collectionView.register(UINib(nibName: String(describing: AccessoryCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AccessoryCollectionViewCell.self))
    
    
    collectionView.panGestureRecognizer.require(toFail: AppConfiguration.shared.appCoordinator.curDisplayingCoordinator().rootVC.interactivePopGestureRecognizer!)

  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIView.noIntrinsicMetric,height: dynamicHeight())
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
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }

}

extension AccessoryHorizentalView: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AccessoryCollectionViewCell.self), for: indexPath) as! AccessoryCollectionViewCell

    cell.setup(indicator.all[indexPath.item], indexPath: indexPath)
    
    return cell
  }
}



