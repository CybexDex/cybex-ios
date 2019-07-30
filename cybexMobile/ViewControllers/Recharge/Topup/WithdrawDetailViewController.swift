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
import Proposer
import Localize_Swift

class WithdrawDetailViewController: BaseViewController {
    
    var containerView: WithdrawView?
    var eosContainerView: EOSWithdrawView?
    
    var trade: Trade?
    var coordinator: (WithdrawDetailCoordinatorProtocol & WithdrawDetailStateManagerProtocol)?
    var isFetching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupData()
    }
    
    func setupData() {
        guard let trade = self.trade else { return }
        self.coordinator?.fetchDepositWordInfo(trade.id)
    }
    
    func setupUI() {
        self.configRightNavButton(R.image.icDepositNew24Px())
        if let trade = self.trade, let name = appData.assetInfo[trade.id]?.symbol.filterSystemPrefix {
            self.title = name + R.string.localizable.withdraw_title.key.localized()
//            let message = Localize.currentLanguage() == "en" ? trade.enInfo: trade.cnInfo
            containerView = WithdrawView(frame: .zero)
            self.view.addSubview(containerView!)
            if trade.tag {
                containerView?.tagView.isHidden = false
            }
            else {
                containerView?.tagView.isHidden = true
            }
            containerView?.needTag = trade.tag
            containerView?.edgesToDevice(vc: self, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), priority: .required, isActive: true, usingSafeArea: true)
//                self.containerView?.introduce.attributedText = message.set(style: StyleNames.withdrawIntroduce.rawValue)
        }
        if self.trade?.enable == false {
            if let errorMsg = Localize.currentLanguage() == "en" ? self.trade?.enMsg : self.trade?.cnMsg {
                showToastBox(false, message: errorMsg)
            }
        } else {
            if UserManager.shared.loginType == .nfc, UserManager.shared.unlockType == .nfc {
                if #available(iOS 11.0, *) {
                    if !UserManager.shared.checkExistCloudPassword() {
                        showPureContentConfirm(R.string.localizable.confirm_hint_title.key.localized(), ensureButtonLocali: R.string.localizable.enotes_feature_add.key, content: R.string.localizable.enotes_feature_hint.key, tag: R.string.localizable.enotes_feature_hint.key.localized())
                    } else {
                        showPasswordBox()
                    }
                }
            } else if UserManager.shared.isLocked {
                showPasswordBox()
            } else {
                self.startLoading()
                if let name = self.trade?.name {
                    self.coordinator?.fetchDepositAddress(name)
                }
            }
        }
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openDepositRecode((self.trade?.name)!)
    }
    
    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().skip(1).subscribe(onNext: {[weak self] (addressInfo) in
            guard let self = self else {return}
            self.endLoading()
            self.isFetching = false
            
            if let info = addressInfo {
                self.containerView?.data = info
            } else {
                main {
                    if ShowToastManager.shared.showView != nil {
                        return
                    }
                    self.showToastBox(false, message: R.string.localizable.noNetwork.key.localized())
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        self.coordinator?.state.msgInfo.asObservable().skip(1).subscribe(onNext: {[weak self] (data) in
            guard let self = self else { return }
            self.containerView?.projectData = data

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func fetchDepositAddress() {
        if self.trade?.enable == false {
            return
        }
        if self.isFetching {
            return
        }
        startLoading()
        self.isFetching = true
        if let name = self.trade?.name {
            self.coordinator?.resetDepositAddress(name)
        }
    }
}

extension WithdrawDetailViewController {
    @objc func resetAddress(_ sender: Any) {
        fetchDepositAddress()
    }
    
    @objc func copyAddress(_ sender: Any) {
        if self.trade?.enable == false {
            return
        }
        let board = UIPasteboard.general
        board.string = containerView?.address.text
        
        self.showToastBox(true, message: R.string.localizable.recharge_copy.key.localized())
    }
    
    @objc func saveCode(_ sender: Any) {
        if self.trade?.enable == false {
            return
        }
        if (self.containerView?.address.text?.count)! <= 0 {
            return
        }
        let photos: PrivateResource = .photos
        proposeToAccess(photos, agreed: {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
                saveImageToPhotos()
                
                self.showToastBox(true, message: R.string.localizable.recharge_save.key.localized())
            }
        }, rejected: {
            let message = R.string.localizable.tip_message.key.localized()
            
            self.showToastBox(false, message: message)
        })
    }
    
    @objc func copyTag(_ sender: Any) {
        if self.trade?.enable == false {
            return
        }
        if let info = sender as? [String: String] {
            let board = UIPasteboard.general
            board.string = info["tag"]
            self.showToastBox(true, message: R.string.localizable.deposit_tag_copy_success.key.localized())
        }
    }
    
    @objc func copyAccount(_ sender: Any) {
        if self.trade?.enable == false {
            return
        }
        let board = UIPasteboard.general
        board.string = eosContainerView?.account.text
        self.showToastBox(true, message: R.string.localizable.eos_copy_account.key.localized())
    }
    
    @objc func copyCode(_ sender: Any) {
        if self.trade?.enable == false {
            return
        }
        if let info = sender as? [String: String] {
            let board = UIPasteboard.general
            board.string = info["memo"]
            self.showToastBox(true, message: R.string.localizable.eos_copy_code.key.localized())
        }
    }
    
    @objc func resetCode(_ sender: Any) {
        fetchDepositAddress()
    }
    
    @objc func openProtocolAddressEvent(_ sender: Any) {
        guard let data = sender as? [String: Any], let url = data["address"] as? String else {
            return
        }
        openPage(url)
    }
}

extension WithdrawDetailViewController {
    override func passwordDetecting() {
        self.startLoading()
    }

    override func passwordPassed(_ passed: Bool) {
        self.endLoading()

        if passed {
            if let name = self.trade?.name {
                self.startLoading()
                self.coordinator?.fetchDepositAddress(name)
            }
        } else {
            if self.isVisible {
                self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
            }
        }
    }

    override func returnEnsureActionWithData(_ tag: String) {
        if tag == R.string.localizable.enotes_feature_hint.key.localized() { // 添加云账户
            pushCloudPasswordViewController(nil)
            return
        }
    }

}
