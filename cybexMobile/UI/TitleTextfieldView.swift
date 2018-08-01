//
//  TitleTextfieldView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/11.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit

typealias TextDidBegainEdit = (() -> Void)
typealias TextDidEndEdit = (() -> Void)
typealias TextDidChanged = (() -> Void)

protocol TitleTextFieldViewDelegate: NSObjectProtocol {
  func textIntroduction(titleTextFieldView : TitleTextfieldView)
  func textActionTrigger(titleTextFieldView: TitleTextfieldView, selected: Bool, index: NSInteger)
}

protocol TitleTextFieldViewDataSource: NSObjectProtocol {
  func textUnitStr(titleTextFieldView: TitleTextfieldView) -> String
  func textUISetting(titleTextFieldView: TitleTextfieldView) -> TitleTextSetting
  func textActionSettings(titleTextFieldView: TitleTextfieldView) -> [TextButtonSetting]
}

@IBDesignable
class TitleTextfieldView: UIView {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var introduceLabel: UILabel!
  
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var gapView: UIView!
  
  @IBOutlet weak var actionsView: UIStackView!
  
  @IBOutlet weak var unitLabel: UILabel!
  
  let TextActionTag = 999
  
  weak var delegate: TitleTextFieldViewDelegate?
  
  weak var datasource: TitleTextFieldViewDataSource? {
    didSet {
      self.reloadData()
    }
  }
  
  var buttonSettings : [TextButtonSetting]? {
    didSet {
      setupRightView()
    }
  }
  
  var unit: String? {
    didSet {
      unitLabel.text = unit
    }
  }
  
  var warningText: String? {
    didSet {
      setting.warningText = warningText ?? ""
    }
  }
  
  var setting : TitleTextSetting! {
    didSet {
      titleLabel.text = setting.title
      
      introduceLabel.text = setting.introduce
      introduceLabel.isUserInteractionEnabled = true
      let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(introduce))
      introduceLabel.addGestureRecognizer(tapGestureRecognizer)
      
      textField.attributedPlaceholder = NSMutableAttributedString.init(string: setting.placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.steel50])
      textField.isSecureTextEntry = setting.isSecureTextEntry
      gapView.alpha = setting.showLine ? 1.0 : 0.0
    }
  }
  
  var checkStatus : TextUIStyle? {
    didSet {
      switch checkStatus! {
      case .highlight:
        highlightUI()
      case .warning:
        redSealUI()
      default:
        recoverUI()
        break
      }
    }
  }
  
  func reloadData() {
    setting = datasource?.textUISetting(titleTextFieldView: self)
    buttonSettings = datasource?.textActionSettings(titleTextFieldView: self)
    unit = datasource?.textUnitStr(titleTextFieldView: self)
  }
  
  func setupRightView() {
    guard (buttonSettings != nil) else {
      return
    }
    if actionsView.arrangedSubviews.count > 0 {
      actionsView.removeArrangedSubviews()
    }
    for (index, value) in (buttonSettings?.enumerated())! {
      let image = UIImage(named: value.imageName)
      let btn = TextRightButton()
      btn.tag = index + TextActionTag
      btn.setImage(image, for: .normal)
      btn.setImage(UIImage(named: value.selectedImageName), for: .selected)
      btn.addTarget(self, action: #selector(handleAction(sender:)), for: .touchUpInside)
      btn.isShowWhenEditing = value.isShowWhenEditing
      btn.width((image?.size.width)! + 5)
      actionsView.addArrangedSubview(btn)
      btn.isHidden = value.isShowWhenEditing
    }
  }
  
  func reloadActionViews(isEditing: Bool) {
    for view in actionsView.arrangedSubviews {
      if let btn = view as? TextRightButton {
        btn.isHidden = btn.isShowWhenEditing && !isEditing
      }
    }
  }
  
  @objc func handleAction(sender: UIButton) {
    sender.isSelected = !sender.isSelected
    delegate?.textActionTrigger(titleTextFieldView: self, selected: sender.isSelected, index: sender.tag - TextActionTag)
  }
  
  func clearText() {
    textField.text = ""
  }
  
  func showPromoptView() {
    
  }
  
  func setup() {
    updateHeight()
  }
  
  @objc func introduce() {
    delegate?.textIntroduction(titleTextFieldView: self)
  }
  
  fileprivate func recoverUI() {
//    titleLabel.text = setting.title
//    titleLabel.textColor = UIColor.steel
//    gapView.backgroundColor = UIColor.paleGreyTwo
  }
  
  fileprivate func redSealUI() {
//    titleLabel.text = setting.warningText
//    titleLabel.textColor = UIColor.scarlet
//    gapView.backgroundColor = UIColor.scarlet
  }
  
  fileprivate func highlightUI() {
//    titleLabel.text = setting.title
//    titleLabel.textColor = UIColor.darkSlateBlue
//    gapView.backgroundColor = UIColor.darkSlateBlue
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  func updateContentSize() {
    self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
    self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
  }
  
  @objc func updateHeight() {
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
