//
//  TransferView.swift
//  cybexMobile
//
//  Created by peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import GrowingTextView

class TransferView: UIView {
  
  @IBOutlet weak var contentView: GrowContentView!
  
  @IBOutlet weak var feeLabel: UILabel!
  
  @IBOutlet weak var transferButton: UIButton!
  
  var crypto: String = "" {
    didSet {
      cryptoView.textField.text = crypto
    }
  }
  
  var balance: String = "" {
    didSet {
      quantityView.unit = balance
    }
  }
  
  var fee: String = "" {
    didSet {
      feeLabel.text = fee
    }
  }
  
  var precision: Int = 0 {
    didSet {
      quantityView.textField.text = ""
    }
  }
  
  var buttonIsEnable: Bool = false {
    didSet {
      transferButton.setBackgroundImage(buttonIsEnable ? R.image.btnColorOrange() : R.image.btnColorGrey(), for: .normal)
      transferButton.isUserInteractionEnabled = buttonIsEnable
      transferButton.alpha = buttonIsEnable ? 1.0 : 0.5
    }
  }
  
  lazy var accountView: TitleTextfieldView = {
    let accountView = TitleTextfieldView()
    return accountView
  }()
  
  lazy var cryptoView: TitleTextfieldView = {
    let cryptoView = TitleTextfieldView()
    return cryptoView
  }()
  
  lazy var quantityView: TitleTextfieldView = {
    let quantityView = TitleTextfieldView()
    return quantityView
  }()
  
  lazy var memoView: TitleTextView = {
    let memoView = TitleTextView()
    return memoView
  }()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadViewFromNib()
    setup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadViewFromNib()
    setup()
  }
  
  func setup() {
    setupUI()
    updateContentSize()
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  func updateContentSize() {
    self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
    self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
  }
  
  @objc fileprivate func updateHeight() {
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
  
  fileprivate func loadViewFromNib() {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib.init(nibName: String.init(describing:type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
  }
  
  enum InputType: Int {
    case account = 1
    case crypto
    case amount
    case memo
  }
  
  enum TextChangeEvent: String {
    case account
    case crypto
    case amount
    case memo
  }
  
  enum TransferEvents: String {
    case selectCrypto
  }
  
  func setupUI() {
    contentView.datasource = self
    setupTextView()
    contentView.updateContentSize()
    updateContentSize()
  }
  
  func setupTextView() {
    self.handleSetupSubTextFiledView(accountView, tag: InputType.account.rawValue)
    self.handleSetupSubTextFiledView(cryptoView, tag: InputType.crypto.rawValue)
    self.handleSetupSubTextFiledView(quantityView, tag: InputType.amount.rawValue)
    quantityView.textField.keyboardType = .decimalPad
    self.handleSubTextView(memoView, tag: InputType.memo.rawValue)
    memoView.textView.minHeight = 90
    memoView.textView.maxHeight = 90
  }
  
  func handleSetupSubTextFiledView(_ titleTextfieldView: TitleTextfieldView, tag: Int) {
    titleTextfieldView.textField.tag = tag
    titleTextfieldView.delegate = self
    titleTextfieldView.datasource = self
    titleTextfieldView.textField.delegate = self
    titleTextfieldView.updateContentSize()
  }
  
  func handleSubTextView(_ titleTextView: TitleTextView, tag: Int) {
    titleTextView.textView.tag = tag
    titleTextView.delegate = self
    titleTextView.datasource = self
    titleTextView.textView.delegate = self
    titleTextView.updateContentSize()
  }
  
}

extension TransferView: GrowContentViewDataSource {
  func numberOfSection(_ contentView: GrowContentView) -> NSInteger {
    return 2
  }
  
  func numberOfRowWithSection(_ contentView: GrowContentView, section: NSInteger) -> NSInteger {
    if section == 0 {
      return 1
    } else {
      return 3
    }
  }
  
  func marginOfContentView(_ contentView: GrowContentView) -> CGFloat {
    return 13.0
  }
  
  func heightWithSectionHeader(_ contentView: GrowContentView, section: NSInteger) -> CGFloat {
    if section == 1 {
      return 13.0
    }
    return 0
  }
  
  func cornerRadiusOfSection(_ contentView: GrowContentView, section: NSInteger) -> CGFloat {
    return 4.0
  }
  
  func shadowSettingOfSection(_ contentView: GrowContentView, section: NSInteger) -> (color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
    return (UIColor.steel,CGSize(width: 0, height: 4),4,0.2)
  }
  
  func viewOfIndexpath(_ contentView: GrowContentView, indexpath: NSIndexPath) -> (view: UIView, key: String) {
    if indexpath.section == 0 {
      return (accountView,"account")
    } else {
      if indexpath.row == 0 {
        return (cryptoView,"crypto")
      } else if indexpath.row == 1 {
        return (quantityView,"quantity")
      } else {
        return (memoView,"memo")
      }
    }
  }
  
}

extension TransferView: TitleTextFieldViewDelegate,TitleTextFieldViewDataSource,TitleTextViewDelegate,TitleTextViewDataSource {
  func textIntroduction(titleTextView: TitleTextView) {
  }
  
  func textActionTrigger(titleTextView: TitleTextView, selected: Bool, index: NSInteger) {
    if index == 0 {
      titleTextView.clearText()
    }
  }
  
  func textUnitStr(titleTextView: TitleTextView) -> String {
    return ""
  }
  
  func textUISetting(titleTextView: TitleTextView) -> TitleTextSetting {
    return TitleTextSetting(title: R.string.localizable.transfer_memo.key.localized(),
                            placeholder: "",
                            warningText: "",
                            introduce: "",
                            isShowPromptWhenEditing: false,
                            showLine: false,
                            isSecureTextEntry: false)
  }
  
  func textActionSettings(titleTextView: TitleTextView) -> [TextButtonSetting] {
    return [TextButtonSetting(imageName: R.image.ic_close_24_px.name,
                              selectedImageName: R.image.ic_close_24_px.name,
                              isShowWhenEditing: true)]
  }
  
  func textIntroduction(titleTextFieldView: TitleTextfieldView) {
  }
  
  func textActionTrigger(titleTextFieldView: TitleTextfieldView, selected: Bool, index: NSInteger) {
    if index == 0 {
      titleTextFieldView.clearText()
    } else {
      if titleTextFieldView == cryptoView {
        self.sendEventWith(TransferEvents.selectCrypto.rawValue, userinfo: [:])
      }
    }
  }
  
  func textUISetting(titleTextFieldView: TitleTextfieldView) -> TitleTextSetting {
    if titleTextFieldView == accountView {
      return TitleTextSetting(title: R.string.localizable.transfer_account.key.localized(),
                              placeholder: R.string.localizable.transfer_account_pla.key.localized(),
                              warningText: "",
                              introduce: "",
                              isShowPromptWhenEditing: false,
                              showLine: false,
                              isSecureTextEntry: false)
    } else if titleTextFieldView == cryptoView {
      return TitleTextSetting(title: R.string.localizable.transfer_crypto.key.localized(),
                              placeholder: R.string.localizable.transfer_crypto_pla.key.localized(),
                              warningText: "",
                              introduce: "",
                              isShowPromptWhenEditing: false,
                              showLine: true,
                              isSecureTextEntry: false)
    } else {
      return TitleTextSetting(title: R.string.localizable.transfer_quantity.key.localized(),
                              placeholder: "",
                              warningText: "",
                              introduce: "",
                              isShowPromptWhenEditing: false,
                              showLine: true,
                              isSecureTextEntry: false)
    }
  }
  
  func textActionSettings(titleTextFieldView: TitleTextfieldView) -> [TextButtonSetting] {
    if titleTextFieldView == cryptoView {
      return [TextButtonSetting(imageName: R.image.ic_close_24_px.name,
                                selectedImageName: R.image.ic_close_24_px.name,
                                isShowWhenEditing: true),
              TextButtonSetting(imageName: R.image.ic_ieo_more.name,
                                selectedImageName: R.image.ic_ieo_more.name,
                                isShowWhenEditing: false)]
    }
    return [TextButtonSetting(imageName: R.image.ic_close_24_px.name,
                              selectedImageName: R.image.ic_close_24_px.name,
                              isShowWhenEditing: true)]
  }
  
  func textUnitStr(titleTextFieldView: TitleTextfieldView) -> String {
    return ""
  }
}

extension TransferView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    switch textField.tag {
    case InputType.crypto.rawValue:
      self.sendEventWith(TransferEvents.selectCrypto.rawValue, userinfo: [:])
      return false
    default:
      return true
    }
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField.tag {
    case InputType.account.rawValue:
      self.sendEventWith(TextChangeEvent.account.rawValue, userinfo: ["content" : textField.text ?? ""])
    default:
      return
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
    switch textField.tag {
    case InputType.amount.rawValue:
      self.sendEventWith(TextChangeEvent.amount.rawValue, userinfo: ["content" : textField.text ?? ""])
      
    case InputType.crypto.rawValue:
      return false
    default:
      return true
    }
  }
}

extension TransferView: GrowingTextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if textView.tag == InputType.memo.rawValue {
      self.sendEventWith(TextChangeEvent.memo.rawValue, userinfo: ["content" : textView.text])
    }
  }
  
  func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
    if textView.tag == InputType.memo.rawValue {
      memoView.updateContentSize()
      contentView.updateContentSize()
      self.updateContentSize()
    }
  }
}

