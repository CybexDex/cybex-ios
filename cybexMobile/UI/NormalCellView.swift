//
//  NormalCellView.swift
//  EOS
//
//  Created by DKM on 2018/7/18.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit

@IBDesignable
class NormalCellView: UIView {
  enum event_name : String {
    case clickCellView
  }
  
  enum NormalCellViewState : Int {
    case normal = 0
    case choose
    case transform
  }
  
  
  @IBOutlet weak var lineView: UIView!
  @IBOutlet weak var leftIcon: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var content: UILabel!
  @IBOutlet weak var rightIcon: UIImageView!
  
  @IBOutlet weak var nameLeftConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var rightIconHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var rightIconWidthConstraint: NSLayoutConstraint!
  
  
  @IBInspectable
  var state : Int = NormalCellViewState.normal.rawValue {
    didSet {
      switch state {
      case NormalCellViewState.normal.rawValue:
        print("")
      case NormalCellViewState.choose.rawValue:
        print("")
      case NormalCellViewState.transform.rawValue:
        self.rightIcon.isHighlighted = true
      default:
        break
      }
    }
  }
  
  @IBInspectable
  var name_locali : String? {
    didSet {
      if let nameLocali = name_locali {
        self.name.locali = nameLocali
      }
    }
  }
  
  @IBInspectable
  var content_locali : String? {
    didSet {
      if let contentLocali = content_locali {
        self.content.locali = contentLocali
      }
    }
  }
  
  @IBInspectable
  var index : Int = 0
  
  @IBInspectable
  var name_text : String? {
    didSet {
      if let text = name_text {
        name.attributedText = text.localized().set(style: name_style ?? "")
      }
    }
  }
  
  @IBInspectable
  var content_text : String? {
    didSet{
      if let text = content_text {
        content.attributedText = text.localized().set(style: content_style ?? "")
      }
    }
  }
  
  @IBInspectable
  var name_style : String? {
    didSet {
      let text = name_text ?? ""
      name.attributedText = text.localized().set(style: name_style ?? "")
    }
  }
  
  @IBInspectable
  var content_style : String? {
    didSet {
      let text = content_text ?? ""
      content.attributedText = text.localized().set(style: content_style ?? "")
    }
  }
  
  @IBInspectable
  var leftIconImg : UIImage? {
    didSet {
      //            if let img = leftIconImg {
      //                if self.state != NormalCellViewState.normal.rawValue {
      //                    return
      //                }
      self.leftIcon.isHidden = false
      self.leftIcon.image = leftIconImg
      nameLeftConstraint.constant = 41
      //            }
    }
  }
  
  @IBInspectable
  var rightIconName : String? {
    didSet{
      if let name = rightIconName {
        if self.state == NormalCellViewState.normal.rawValue {
          return
        }
        self.rightIcon.image = UIImage(named: name)
        rightIconHeightConstraint.constant = 20
        rightIconWidthConstraint.constant = 20
      }
    }
  }
  
  @IBInspectable
  var isShowLineView : Bool = false {
    didSet{
      self.lineView.isHidden = isShowLineView
    }
  }
  
  @IBInspectable
  var isEnable : Bool = true {
    didSet {
      self.isUserInteractionEnabled = isEnable
    }
  }
  
  
  var data : Any? {
    didSet {
      
    }
  }
  
  func setup() {
    self.state = NormalCellViewState.normal.rawValue
    let tap = UITapGestureRecognizer(target: self, action: #selector(clickCellView))
    self.addGestureRecognizer(tap)
    
    
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  func updateHeight() {
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

extension NormalCellView {
  @objc func clickCellView(){
    
    switch self.state {
    case NormalCellViewState.normal.rawValue:
      self.sendEventWith(event_name.clickCellView.rawValue, userinfo: ["index":index])
    case NormalCellViewState.choose.rawValue :
      self.sendEventWith(event_name.clickCellView.rawValue, userinfo: ["index":index])
    case NormalCellViewState.transform.rawValue:
      print("")
      
    default:break
    }
  }
}


