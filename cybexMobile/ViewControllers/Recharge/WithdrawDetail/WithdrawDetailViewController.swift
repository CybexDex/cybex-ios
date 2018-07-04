//
//  WithdrawDetailViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import EFQRCode
import Proposer
import Localize_Swift

class WithdrawDetailViewController: BaseViewController {
  
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var introduce: UILabel!
    
    @IBOutlet weak var resetAddress: UIButton!
    
    @IBOutlet weak var copyAddress: UIButton!
    
  var trade : Trade?
  var coordinator: (WithdrawDetailCoordinatorProtocol & WithdrawDetailStateManagerProtocol)?
  var isFetching : Bool = false
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    
  }
  
  func setupUI(){
    if let name = app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade{
      self.title = name + R.string.localizable.withdraw_title.key.localized()
      self.coordinator?.fetchDepositMessage(callback: { (message) in
        if message.count > 0 {
          self.introduce.attributedText = message.replacingOccurrences(of: "$asset", with: name).set(style: StyleNames.introduce_normal.rawValue)
        }
      })
    }
    if UIScreen.main.bounds.width == 320 {
      resetAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
      copyAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    }
    
    if self.trade?.enable == false{
      if let errorMsg = Localize.currentLanguage() == "en" ? self.trade?.enMsg : self.trade?.cnMsg {
        showToastBox(false, message: errorMsg)
      }
    }else{
      if let balance = self.trade?.id, let name = app_data.assetInfo[balance]?.symbol.filterJade{
        startLoading()
        self.coordinator?.fetchDepositAddress(name)
      }
    }
  }
  
  @IBAction func saveIcon(_ sender: Any) {
    if self.trade?.enable == false{
      return
    }
    if (self.address.text?.count)! <= 0 {
      return
    }
    let photos: PrivateResource = .photos
    proposeToAccess(photos, agreed: {
      print("I can access Photos. :]\n")
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
        saveImageToPhotos()
    
        self.showTopToastBox(true, message:R.string.localizable.recharge_save.key.localized())
      }
    }, rejected: {
      let message = R.string.localizable.tip_message.key.localized()
     
      self.showToastBox(false, message: message)
    })    
  }
  
  @IBAction func copyAddress(_ sender: Any) {
    if self.trade?.enable == false{
      return
    }
    let board = UIPasteboard.general
    board.string = address.text

    self.showToastBox(true, message: R.string.localizable.recharge_copy.key.localized())
  }
  
  @IBAction func resetAddress(_ sender: Any) {
    if self.trade?.enable == false{
      return
    }
    if self.isFetching {
      return
    }
    startLoading()
    self.isFetching = true
    let name = app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade
    self.coordinator?.resetDepositAddress(name!)
  }
  
  func commonObserveState() {
    coordinator?.subscribe(errorSubscriber) { sub in
      return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    
    coordinator?.subscribe(loadingSubscriber) { sub in
      return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    self.coordinator?.state.property.data.asObservable().skip(1).subscribe(onNext: {[weak self] (addressInfo) in
      guard let `self` = self else{return}
      self.endLoading()
      self.isFetching = false
      if let info = addressInfo{
        self.address.text = info.address
        print("address : \(info.address)")
        if let tryImage = EFQRCode.generate(
          content: info.address,
          size: EFIntSize(width: 100, height: 100),
          watermark: UIImage(named: R.image.artboard.name)?.toCGImage()
          ) {
          self.icon.image = UIImage(cgImage: tryImage)
          print("Create QRCode image success: \(tryImage)")
        } else {
          print("Create QRCode image failed!")
        }
      }else{
        main {
          if ShowManager.shared.showView != nil{
            return
          }
          self.showTopToastBox(false, message: R.string.localizable.recharge_retry.key.localized())
        }
      }
      
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  override func configureObserveState() {
    commonObserveState()
  }
}
