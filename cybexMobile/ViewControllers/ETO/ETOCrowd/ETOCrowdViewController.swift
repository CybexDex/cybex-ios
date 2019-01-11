//
//  ETOCrowdViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Repeat

class ETOCrowdViewController: BaseViewController {

	var coordinator: (ETOCrowdCoordinatorProtocol & ETOCrowdStateManagerProtocol)?

    @IBOutlet var contentView: ETOCrowdView!
    var timerRepeater: Repeater?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startTimeRepeatAction()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timerRepeater?.pause()
        self.timerRepeater = nil
    }

    func startTimeRepeatAction() {
        self.timerRepeater = Repeater.every(.seconds(3), { [weak self](_) in
            main {
                guard let self = self else { return }
                self.coordinator?.fetchUserRecord()
            }
        })
    }

    override func refreshViewController() {

    }

    func setupUI() {
        self.contentView.actionButton.isEnabled = false
    }

    func setupData() {
        self.coordinator?.fetchData()
        self.coordinator?.fetchUserRecord()
        self.coordinator?.fetchFee()
    }

    func setupEvent() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self.contentView.titleTextView.textField, queue: nil) {[weak self] (_) in
            guard let self = self else { return }

            self.coordinator?.unsetValidStatus()
        }

        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self.contentView.titleTextView.textField, queue: nil) {[weak self] (_) in
            guard let self = self, let amount = self.contentView.titleTextView.textField.text?.decimal() else { return }

            self.coordinator?.checkValidStatus(amount)
        }
    }

    override func configureObserveState() {
        coordinator?.state.pageState.asObservable().subscribe(onNext: { (_) in
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.data.asObservable().subscribe(onNext: {[weak self] (model) in
            guard let self = self, let model = model else { return }
            self.navigationItem.title = model.name + " ETO"
            self.contentView.updateUI(model, handler: ETOCrowdView.adapterModelToETOCrowdView(self.contentView))
        }).disposed(by: disposeBag)

        coordinator?.state.userData.asObservable().subscribe(onNext: {[weak self] (model) in
            guard let self = self, let model = model, let project = self.coordinator?.state.data.value else { return }

            self.contentView.updateUI((projectModel:project, userModel:model), handler: ETOCrowdView.adapterModelToUserCrowdView(self.contentView))
        }).disposed(by: disposeBag)

        coordinator?.state.fee.asObservable().subscribe(onNext: {[weak self] (model) in
            if let self = self, let data = model, let feeInfo = appData.assetInfo[data.assetId] {
                let feeAmount = data.amount.decimal().formatCurrency(digitNum: feeInfo.precision)
                self.contentView.priceLabel.text = feeAmount + " " + feeInfo.symbol.filterJade
            }
        }).disposed(by: disposeBag)

        coordinator?.state.validStatus.asObservable().subscribe(onNext: {[weak self] (status) in
            guard let self = self else { return }

            if case .notValid = status {
                self.contentView.actionButton.isEnabled = false
                self.contentView.errorView.isHidden = true
                return
            }

            if case .ok = status {
                self.contentView.errorView.isHidden = true
                self.contentView.actionButton.isEnabled = true
            } else {
                self.contentView.actionButton.isEnabled = false
                self.contentView.errorView.isHidden = false
                self.contentView.errorLabel.text = status.desc()
            }

        }).disposed(by: disposeBag)

    }
}

// MARK: - View Event
extension ETOCrowdViewController {
    @objc func ETOCrowdButtonDidClicked(_ data: [String: Any]) {
        self.view.endEditing(true)

        if UserManager.shared.isLocked {
            self.showPasswordBox()
            return
        }

        guard let price = self.contentView.titleTextView.textField.text else { return }

        self.coordinator?.showConfirm(price.decimal())
    }

    override func returnEnsureAction() {
        guard let price = self.contentView.titleTextView.textField.text?.decimal() else { return }
        self.startLoading()
        self.coordinator?.joinCrowd(price, callback: { [weak self](data) in
            guard let self = self else { return }
            self.endLoading()
            if String(describing: data) == "<null>" {
                self.showWaiting(R.string.localizable.eto_transfer_title.key.localized(), content: R.string.localizable.eto_transfer_content.key.localized(), time: 5)
            } else {
                self.showToastBox(false, message: R.string.localizable.transfer_failed.key.localized())
            }
        })
    }

    override func ensureWaitingAction(_ sender: CybexWaitingView) {
        ShowToastManager.shared.hide(0)
        self.coordinator?.reOpenCrowd()
    }

    override func passwordDetecting() {
        self.startLoading()
    }

    override func passwordPassed(_ passed: Bool) {
        self.endLoading()
        if passed == true {
            guard let price = self.contentView.titleTextView.textField.text else { return }
            self.coordinator?.showConfirm(price.decimal())
        } else {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }
}
