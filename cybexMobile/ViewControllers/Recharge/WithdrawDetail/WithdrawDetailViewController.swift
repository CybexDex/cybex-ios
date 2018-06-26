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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    
  }
  
  func setupUI(){
    if UIScreen.main.bounds.width == 320 {
        resetAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        copyAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    }
    self.coordinator?.fetchDepositMessage(callback: { (message) in
      if message.count > 0 {
        self.introduce.text = message
      }
    })
    
    if self.trade?.enable == false{
      let name = app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade
      var message = ""
      if Localize.currentLanguage() == "en"{
        message = "Unable to deposit \(String(describing: name)) for a short time, please retry later"
      }else{
        message = "\(String(describing: name))暂停充值"
      }
      
      ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: message, animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
    }else{
      if let balance = self.trade?.id, let name = app_data.assetInfo[balance]?.symbol.filterJade{
        startLoading()
        self.coordinator?.fetchDepositAddress(name)
      }
    }
  }
  
  @IBAction func saveIcon(_ sender: Any) {
    
    let photos: PrivateResource = .photos
    proposeToAccess(photos, agreed: {
      print("I can access Photos. :]\n")
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
        saveImageToPhotos()
        ShowManager.shared.setUp(title_image: R.image.icCheckCircleGreen.name, message: R.string.localizable.recharge_save.key.localized(), animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
        ShowManager.shared.showAnimationInView(self.view)
        ShowManager.shared.hide(2)
      }
    }, rejected: {
      var title = ""
      var message = ""
      if Localize.currentLanguage() == "en"{
        title = "Tip"
        message = "Please open photo album permissions in Settings"
      }else{
        title = "提示"
        message = "请在设置中打开相册权限"
      }
      ShowManager.shared.setUp(title: title, message: message, animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
    })    
  }
  
  @IBAction func copyAddress(_ sender: Any) {
    let board = UIPasteboard.general
    board.string = address.text
    
    ShowManager.shared.setUp(title_image: R.image.icCheckCircleGreen.name, message: R.string.localizable.recharge_copy.key.localized(), animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
    ShowManager.shared.showAnimationInView(self.view)
    ShowManager.shared.hide(2)
    
  }
  
  @IBAction func resetAddress(_ sender: Any) {
    startLoading()
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
      if let info = addressInfo{
        self.address.text = info.address
        print("address : \(info.address)")
        if let tryImage = EFQRCode.generate(
          content: info.address,
          size: EFIntSize(width: 100, height: 100),
          
          watermark: UIImage(named: R.image.icon_code.name)?.toCGImage()
          ) {
          self.icon.image = UIImage(cgImage: tryImage)
          print("Create QRCode image success: \(tryImage)")
        } else {
          print("Create QRCode image failed!")
        }
      }else{
        main {
          ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: R.string.localizable.recharge_retry.key.localized(), animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
          ShowManager.shared.showAnimationInView(self.view)
          ShowManager.shared.hide(2)
        }
      }
      
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  override func configureObserveState() {
    commonObserveState()
  }
}
