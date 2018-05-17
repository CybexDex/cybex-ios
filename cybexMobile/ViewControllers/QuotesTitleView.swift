//
//  QuotesTitleView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/17.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class QuotesTitleView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  var titles : [String] = []{
    didSet{
      setupUI()
    }
  }
  
  fileprivate var btns : [UIButton] = []
  
  struct item_property {
    static let space                   = 36.0
    static let width                     = 35.0
    static let height                  = 18.0
    static let normalColor : UIColor   = .steel
    static let selectedColor : UIColor = .white
    static let font : CGFloat          = 16.0
  }
  // 创建UI内容
  func setupUI(){
    let scrollView = UIScrollView.init(frame: self.bounds)
    scrollView.showsHorizontalScrollIndicator = false
    addSubview(scrollView)
    for i in 1...titles.count-1 {
      let btn : UIButton = UIButton.init(frame: CGRect(x: CGFloat(22.0 + Double(i) * (item_property.width+item_property.space)), y: 6, w: CGFloat(item_property.width), h: CGFloat(item_property.height)))
      btn.setTitle(titles[i], for: .normal)
      btn.setTitleColor(item_property.normalColor, for: .normal)
      btn.setTitleColor(item_property.selectedColor, for: .selected)
      btn.titleLabel?.font = UIFont.systemFont(ofSize: item_property.font)
      btn.addTarget(self, action: #selector(self.changeTitle(_:)), for: .touchUpInside)
      btn.tag = 100+i
      scrollView.addSubview(btn)
      btns.append(btn)
    }
    scrollView.contentSize = CGSize(width:22.0 + Double(titles.count) *  (item_property.width+item_property.space), height: 0)
  }
  
  @objc func changeTitle(_ sender:UIButton){
    for btn in btns{
      if btn == sender{
        btn.isSelected = true
      }else{
        btn.isSelected = false
      }
    }
    // 判断sender的tag值 对应不同的点击事件
  }
  
  
}
