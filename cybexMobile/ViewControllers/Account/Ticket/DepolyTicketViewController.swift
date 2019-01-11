//
//  DepolyTicketViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/9.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import Presentr
import RxCocoa
import RxSwift

class DepolyTicketViewController: BaseViewController {
    var containView: DeployTicketView!

    var result: String?
    var chooseAssetname: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = R.string.localizable.ticket_title.key.localized()

        setupUI()
        self.containView.buttonIsEnable = false

        setupEvent()
    }

    func setupUI() {
        let scroll = UIScrollView(frame: self.view.frame.inset(by: self.view.windowWithNavSafeAreaInsets))
        self.containView = DeployTicketView(frame: scroll.bounds)
        scroll.addSubview(self.containView)
        scroll.contentSize = scroll.size
        self.view.addSubview(scroll)
    }

    func setupEvent() {
        Observable.combineLatest(containView.accountView.textField.rx.text.orEmpty,
                                 containView.assetView.textField.rx.text.orEmpty,
                                 containView.amountView.textField.rx.text.orEmpty).subscribe(onNext: {[weak self] (validate) in
                                    guard let self = self else { return }

                                    if !validate.0.isEmpty, !validate.1.isEmpty, !validate.2.isEmpty {
                                        self.containView.buttonIsEnable = true
                                    } else {
                                        self.containView.buttonIsEnable = false
                                    }

                                    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

// MARK: - Logic
extension DepolyTicketViewController {
    func getAccountId() {

    }

    func getAssetId() {

    }

    func generateInfo() {
        
    }
}

// MARK: - Route
extension DepolyTicketViewController {
    func presentAssetPicker(_ assetChoosed: @escaping (String) -> Void) {
        let width = ModalSize.full
        let height = ModalSize.custom(size: 244)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let presenter = Presentr(presentationType: customType)
        presenter.dismissOnTap = true
        presenter.keyboardTranslationType = .moveUp

        var items = [String]()
        let balances = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
            return AssetHelper.getRealAmount(balance.assetType, amount: balance.balance) != 0
        })

        if let balances = balances {
            for balance in balances {
                items.append(balance.assetType.symbol.filterJade)
            }
        }

        if items.count == 0 {
            items.append(R.string.localizable.balance_nodata.key.localized())
        }

        var context = PickerContext()
        context.items = items as AnyObject
        context.pickerDidSelected = {(picker: UIPickerView) -> Void in
            let balance = balances![picker.selectedRow(inComponent: 0)]

            assetChoosed(balance.assetType.symbol.filterJade)
        }

        let nav = BaseNavigationController()
        let coor = NavCoordinator(rootVC: nav)
        coor.pushVC(PickerCoordinator.self, animated: false, context: context)

        var topside = self.navigationController

        while topside?.presentedViewController != nil {
            topside = topside?.presentedViewController as? BaseNavigationController
        }

        if let top = topside {
            top.customPresentViewController(presenter, viewController: nav, animated: true)
        }
    }
}

// MARK: - Event
extension DepolyTicketViewController {
    @objc func scan(_ data: [String: Any]) {
        let vc = ScanViewController()
        vc.scanResult.delegate(on: self) { (self, result) in
            self.result = result
        }
        self.navigationController?.pushViewController(vc)
    }

    @objc func chooseAsset(_ data: [String: Any]) {
        presentAssetPicker {[weak self] (asset) in
            guard let self = self else { return }

            self.chooseAssetname = asset
            self.containView.assetView.textField.text = asset
        }
    }

    @objc func deploy(_ data: [String: Any]) {
//        guard let result = result, let chooseAssetname = chooseAssetname else { return }
        let vc = DeployTicketResultViewController()
        vc.qrcodeInfo = "result"
        vc.assetName = "CYB"
        self.navigationController?.pushViewController(vc)
    }
}
