//
//  AccountContentView.swift
//  cybexMobile
//
//  Created by zhusongyu on 2018/7/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class AccountContentView: UIView {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerView: AccountTableHeadView!

  enum event: String {
    case myproperty
    case accounttrade
    case ordervalue
    case lockupassets
  }

  var data: Any? {
    didSet {
      if data is [AccountViewModel] {
        tableView.reloadData()
      }
    }
  }

  func setup() {
    let nibString = R.nib.normalContentCell.name
    tableView.register(UINib.init(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
    updateHeight()
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

extension AccountContentView: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let data = data as? [AccountViewModel] {
      return data.count
    }
    return 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: NormalContentCell.self), for: indexPath) as! NormalContentCell

    if let data = data as? [AccountViewModel] {
      cell.setup(data[indexPath.row], indexPath: indexPath)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 54
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.row {
    case 0:
      self.sendEventWith(event.myproperty.rawValue, userinfo: [:])
    case 1:
      self.sendEventWith(event.accounttrade.rawValue, userinfo: [:])
    case 2:
      self.sendEventWith(event.ordervalue.rawValue, userinfo: [:])
    default:
      self.sendEventWith(event.lockupassets.rawValue, userinfo: [:])
    }

  }
}
