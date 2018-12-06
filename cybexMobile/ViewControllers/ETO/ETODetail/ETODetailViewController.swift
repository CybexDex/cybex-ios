//
//  ETODetailViewController.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Repeat

class ETODetailViewController: BaseViewController {

	var coordinator: (ETODetailCoordinatorProtocol & ETODetailStateManagerProtocol)?
    private(set) var context: ETODetailContext?

    @IBOutlet weak var contentView: ETODetailView!

    var timerRepeater: Repeater?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startRepeatAction()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timerRepeater!.pause()
        self.timerRepeater = nil
    }

    func startRepeatAction() {
        self.timerRepeater = Repeater.every(.seconds(1), { [weak self](_) in
            main {
                guard let self = self else { return }
                self.coordinator?.updateETOProjectDetailAction()
                self.coordinator?.fetchUserState()
            }
        })
    }

    override func refreshViewController() {

    }

    func setupUI() {
        self.localizedText = R.string.localizable.eto_project_detail_title.key.localizedContainer()
//        configRightNavButton(R.image.ic_share_24_px())
    }

    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openShare()
    }

    func setupData() {
        self.startLoading()
        self.coordinator?.fetchData()
        self.coordinator?.fetchUserState()
    }

    func setupEvent() {

    }

    override func configureObserveState() {
        self.coordinator?.state.context.asObservable().subscribe(onNext: { [weak self] (context) in
            guard let self = self else { return }

            if let context = context as? ETODetailContext {
                self.context = context
            }
        }).disposed(by: disposeBag)

        coordinator?.state.pageState.asObservable().subscribe(onNext: {[weak self] (state) in
            guard let self = self else { return }
            if case let .error(error, _) = state {
                self.endLoading()
                self.showToastBox(false, message: error.localizedDescription)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.data.asObservable().subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            self.endLoading()
            if let model = data {
                self.contentView.adapterModelToETODetailView(model)
                self.contentView.data = model
                self.title = model.name + " ETO"
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.refreshData.asObservable().subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            main {
                if let model = data {
                    self.contentView.headerView.adapterModelToETODetailHeaderView(model)
                    self.coordinator?.fetchUpState()
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.userState.asObservable().subscribe(onNext: { [weak self]data in
            guard let self = self else { return }
            main {
                if let _ = data {
                    self.coordinator?.fetchUpState()
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension ETODetailViewController {
    @objc func clickCellView(_ data: [String: Any]) {
        if let url = data["data"] as? String {
            self.coordinator?.openWebWithUrl(url, type: CybexWebViewController.WebType.whitelist)
        }
    }

    @objc func crowdPage(_ data: [String: Any]) {
        self.coordinator?.openETOCrowdVC()
    }

    @objc func loginPage(_ data: [String: Any]) {
        appCoodinator.showLogin()
    }

    @objc func unset(_ data: [String: Any]) {

    }

    @objc func inputCode(_ data: [String: Any]) {
        self.showPasswordBox(R.string.localizable.eto_invite_code_title.key.localized(), middleType: .time)
    }

    @objc func icoapePage(_ data: [String: Any]) {
        self.coordinator?.openWebWithUrl("https://icoape.com/", type: CybexWebViewController.WebType.kyc)
    }

    override func returnInviteCode(_ sender: String) {
        self.coordinator?.checkInviteCode(code: sender, callback: { (success, errorDescription) in
            if success == true {
                ShowToastManager.shared.hide(0)
                self.showConfirmImage(R.image.icCheckCircleGreen.name, title: R.string.localizable.eto_appointment_success.key.localized(), content: "")
            } else {
                ShowToastManager.shared.data = errorDescription
            }
        })
    }

    @objc func labelClick(_ sender: [String: Any]) {
        if let url = sender["clicklabel"] as? String {
            self.coordinator?.openWebWithUrl(url, type: CybexWebViewController.WebType.projectWebsite)
        }
    }

    @objc func showToastError(_ sender: [String: Any]) {
        self.showToastBox(false, message: R.string.localizable.eto_detail_user_agreement_error.key.localized())
    }

    @objc func showAgreement(_ sender: [String: Any]) {
        self.coordinator?.openWebWithUrl("", type: CybexWebViewController.WebType.agreement)
    }
}
