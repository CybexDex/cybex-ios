//
//  TransferView.swift
//  cybexMobile
//
//  Created by peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class TransferView: UIView {
  
  @IBOutlet weak var contentView: GrowContentView!
  
  @IBOutlet weak var feeLabel: UILabel!
  
  @IBOutlet weak var transferButton: UIButton!
  
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
  
  func setupUI() {
    contentView.datasource = self
    setupTextView()
    contentView.updateContentSize()
    updateContentSize()
  }
  
  func setupTextView() {
    self.handleSetupSubTextFiledView(accountView)
    self.handleSetupSubTextFiledView(cryptoView)
    self.handleSetupSubTextFiledView(quantityView)
    self.handleSubTextView(memoView)
  }
  
  func handleSetupSubTextFiledView(_ titleTextfieldView : TitleTextfieldView) {
    titleTextfieldView.delegate = self
    titleTextfieldView.datasource = self
    titleTextfieldView.updateContentSize()
  }
  
  func handleSubTextView(_ titleTextView : TitleTextView) {
    titleTextView.delegate = self
    titleTextView.datasource = self
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
  
  func shadowSettingOfSection(_ contentView: GrowContentView, section: NSInteger) -> (color: UIColor, offset: CGSize, radius: CGFloat) {
    return (UIColor.steel20,CGSize(width: 0, height: 8),8)
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
                              isSecureTextEntry: true)
    } else {
      return TitleTextSetting(title: R.string.localizable.transfer_quantity.key.localized(),
                              placeholder: "",
                              warningText: "",
                              introduce: "",
                              isShowPromptWhenEditing: false,
                              showLine: true,
                              isSecureTextEntry: true)
    }
  }
  
  func textActionSettings(titleTextFieldView: TitleTextfieldView) -> [TextButtonSetting] {
    return [TextButtonSetting(imageName: R.image.ic_close_24_px.name,
                              selectedImageName: R.image.ic_close_24_px.name,
                              isShowWhenEditing: true)]
  }
  
  func textUnitStr(titleTextFieldView: TitleTextfieldView) -> String {
    return ""
  }
}

