//
//  CloudPasswordSettingViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/3/11.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import UIKit
import SwiftTheme
import RxSwift
import RxCocoa
import SwiftyJSON
import cybex_ios_core_cpp

class CloudPasswordSettingViewController: BaseViewController {

    @IBOutlet weak var passwordTextField: ImageTextField!
    @IBOutlet weak var confirmPasswordTextField: ImageTextField!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var passwordRuleHint: UILabel!
    @IBOutlet weak var ensureButton: Button!
    @IBOutlet weak var hintLabel: BaseLabel!
    
    var passwordValid = false
    var confirmValid = false
    var card: Card? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = R.string.localizable.enotes_cloudpassword_title.key.localized()
        setupUI()

        setupPasswordEvent()
        setupRegisterButtonEvent()
    }

    func setupUI() {
        passwordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        confirmPasswordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        passwordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        confirmPasswordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey

        passwordTextField.activityView?.isHidden = true
        passwordTextField.tailImage = nil
        confirmPasswordTextField.activityView?.isHidden = true
        confirmPasswordTextField.tailImage = nil

        self.hintLabel.locali = R.string.localizable.enotes_cloudpassword_set_hint.key
    }

    func setupPasswordEvent() {
        let passwordValid = self.passwordTextField.rx.text.orEmpty.map({ UserHelper.verifyPassword($0) }).share(replay: 1)
        let confirmPasswordValid = self.confirmPasswordTextField.rx.text.orEmpty.map({ UserHelper.verifyPassword($0) }).share(replay: 1)

        passwordValid.subscribe(onNext: {[weak self] (validate) in
            guard let self = self else { return }
            self.passwordValid = validate
            if validate {
                self.passwordTextField.tailImage = R.image.check_complete()
                if let confirm = self.confirmPasswordTextField.text, confirm.count > 0, self.passwordTextField.text != confirm {
                    self.errorStackView.isHidden = false
                    self.passwordRuleHint.text = R.string.localizable.passwordValidateError2.key.localized()
                    self.passwordTextField.tailImage = nil
                    return
                }

                self.errorStackView.isHidden = true
            } else {
                self.passwordTextField.tailImage = nil
                if let text = self.passwordTextField.text, text.count == 0 {
                    if !self.confirmValid, let confirm = self.confirmPasswordTextField.text, confirm.count > 0 {
                        self.errorStackView.isHidden = false
                        self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
                        return
                    }

                    self.errorStackView.isHidden = true
                    return
                }
                self.errorStackView.isHidden = false
                self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        confirmPasswordValid.subscribe(onNext: {[weak self] (validate) in
            guard let self = self else { return }
            self.confirmValid = validate

            if validate {
                self.confirmPasswordTextField.tailImage = R.image.check_complete()
                if !self.passwordValid || self.passwordTextField.text != self.confirmPasswordTextField.text {
                    self.errorStackView.isHidden = false
                    self.confirmPasswordTextField.tailImage = nil
                    self.passwordRuleHint.text = R.string.localizable.passwordValidateError2.key.localized()
                    return
                }

                self.errorStackView.isHidden = true
            } else {
                self.confirmPasswordTextField.tailImage = nil
                if let text = self.confirmPasswordTextField.text, text.count == 0 {
                    if !self.passwordValid, let password = self.passwordTextField.text, password.count > 0 {
                        self.errorStackView.isHidden = false
                        self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
                        return
                    }

                    self.errorStackView.isHidden = true
                    return
                }
                self.errorStackView.isHidden = false
                self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        let consistent = Observable.combineLatest(self.passwordTextField.rx.text, self.confirmPasswordTextField.rx.text).map({$0 == $1})

        Observable.combineLatest(passwordValid, confirmPasswordValid, consistent).subscribe(onNext: {[weak self] (cond) in
            guard let self = self else { return }

            self.ensureButton.isEnable = cond.0 && cond.1 && cond.2

        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }

    func setupRegisterButtonEvent() {
        self.ensureButton.rx.tapGesture().when(.recognized).filter {[weak self] (_) -> Bool in
            guard let self = self else { return false }

            return self.ensureButton.canRepeat

            }.subscribe(onNext: {[weak self] (_) in
                guard let self = self else { return }

                self.ensureButton.canRepeat = false

                self.startLoading()

                let password = self.passwordTextField.text ?? ""
                
                if let name = UserManager.shared.name.value, let accountkeys = UserManager.shared.generateAccountKeys(name, password: password) {
                    CybexDatabaseApiService.request(target: .getAccount(name: name), success: { (json) in
                        guard let operation = self.compositeOperation(json, accountkeys: accountkeys) else {
                            return
                        }

                        CybexChainHelper.calculateFee(operation,
                                                      operationID: OperationId.accountUpdate, focusAssetId: AssetConfiguration.CybexAsset.CYB.id) { (success, amount, assetID) in
                                                        if success {
                                                            guard let newOperation = self.updateFeeOfOperation(operation, amount: amount) else {
                                                                return
                                                            }

                                                            CybexChainHelper.blockchainParams { (blockchainParams) in
                                                                if #available(iOS 11.0, *) {
                                                                    NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                                                                        BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)

                                                                        let jsonstr = BitShareCoordinator.updateAccount(blockchainParams.block_num.int32, block_id: blockchainParams.block_id, expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration, chain_id: CybexConfiguration.shared.chainID.value, operation: newOperation)
                                                                        let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                                                                            self.endLoading()
                                                                            if String(describing: data) == "<null>"{
                                                                                self.showToastBox(true, message: R.string.localizable.enotes_cloudPassword_add_success.key.localized())
                                                                                UserManager.shared.unlock(name, password: password).done({ (fullaccount) in
                                                                                    UserManager.shared.handlerFullAcount(fullaccount)
                                                                                }).cauterize()

                                                                                delay(milliseconds: 1000) {
                                                                                    self.navigationController?.popViewController()
                                                                                }

                                                                            } else {
                                                                                self.ensureButton.canRepeat = true
                                                                                self.showToastBox(false, message: R.string.localizable.enotes_cloudPassword_add_fail.key.localized())
                                                                            }
                                                                        }, jsonstr: jsonstr)

                                                                        CybexWebSocketService.shared.send(request: withdrawRequest)

                                                                    }
                                                                    NFCManager.shared.start()
                                                                }



                                                            }
                                                        }
                        }

                    }, error: { (error) in

                    }, failure: { (error) in

                    })



                }



            }).disposed(by: disposeBag)
    }

    func compositeOperation(_ fullaccount: JSON, accountkeys: AccountKeys) -> String? {
        guard let id = fullaccount[0][1]["account"]["id"].rawString(),
            var active = fullaccount[0][1]["account"]["active"].dictionaryObject,
            var activeKeyAuths = active["key_auths"] as? [Any],
            var options = fullaccount[0][1]["account"]["options"].dictionaryObject,
            let ownerKey = accountkeys.ownerKey?.publicKey
        else {
                return nil
        }

        activeKeyAuths.append([ownerKey, 1])
        active["key_auths"] = activeKeyAuths
        options["memo_key"] = ownerKey

        let dic = ["fee": ["amount": 0, "asset_id": AssetConfiguration.CybexAsset.CYB.id],
                   "account": id,
                   "active": active,
                   "new_options": options,
                   "extensions":[:]
            ] as [String : Any]

        return JSON(dic).rawString()
    }

    func updateFeeOfOperation(_ op: String, amount: Decimal) -> String? {
        guard var json = JSON(parseJSON: op).dictionaryObject,
            var fee = json["fee"] as? [String: Any],
            let asset = appData.assetInfo[AssetConfiguration.CybexAsset.CYB.id]
            else {
                return nil
        }

        fee["amount"] = (amount * pow(10, asset.precision)).int64Value

        json["fee"] = fee

        return JSON(json).rawString()
    }

}
