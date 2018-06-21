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

class WithdrawDetailViewController: BaseViewController {
  
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var icon: UIImageView!
  var withdrawId : String?
  var coordinator: (WithdrawDetailCoordinatorProtocol & WithdrawDetailStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startLoading()
    if let balance = self.withdrawId, let name = app_data.assetInfo[balance]?.symbol.filterJade{
      self.coordinator?.fetchDepositAddress(name)
    }
  }
  
  @IBAction func saveIcon(_ sender: Any) {
    
    let photos: PrivateResource = .photos
    proposeToAccess(photos, agreed: {
      print("I can access Photos. :]\n")
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
        saveImageToPhotos()
        ShowManager.shared.setUp(title_image: "icCheckCircleGreen", message: "已保存二维码", animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
        ShowManager.shared.showAnimationInView(self.view)
        ShowManager.shared.hide(2)
      }
    }, rejected: {
      ShowManager.shared.setUp(title: "提示", message: "请在设置中打开相册权限", animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
    })    
  }
  
  @IBAction func copyAddress(_ sender: Any) {
    let board = UIPasteboard.general
    board.string = address.text
    
    ShowManager.shared.setUp(title_image: "icCheckCircleGreen", message: "已复制地址", animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
    ShowManager.shared.showAnimationInView(self.view)
    ShowManager.shared.hide(2)
    
  }
  
  @IBAction func resetAddress(_ sender: Any) {
    startLoading()
    let name = app_data.assetInfo[(self.withdrawId)!]?.symbol.filterJade
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
          watermark: UIImage(named: "icon_code")?.toCGImage()
          ) {
          self.icon.image = UIImage(cgImage: tryImage)
          print("Create QRCode image success: \(tryImage)")
        } else {
          print("Create QRCode image failed!")
        }
      }else{
        main {
          ShowManager.shared.setUp(title_image: "erro16Px", message: "请在5分钟后重新生成", animationType: ShowManager.ShowAnimationType.up_down, showType: ShowManager.ShowManagerType.sheet_image)
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
