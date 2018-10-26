//
//  ETOViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import Repeat

class ETOViewController: BaseViewController {

    var coordinator: (ETOCoordinatorProtocol & ETOStateManagerProtocol)?
    @IBOutlet weak var homeView: ETOHomeView!
//    var timerRepeater: Repeater?
    var infosRepeater: Repeater?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()
    }

    override func refreshViewController() {

    }

    func startInfosRepeatAction() {
        self.infosRepeater = Repeater.every(.seconds(3), { [weak self](_) in
            main {
                guard let `self` = self else { return }
                self.coordinator?.refreshProjectDatas()
                self.coordinator?.refreshTime()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchProjectData()
        self.fetchBannder()
        self.startInfosRepeatAction()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.infosRepeater?.pause()
        self.infosRepeater = nil
    }

    func setupUI() {
        setupNaviUI()
    }

    func setupNaviUI() {
        self.automaticallyAdjustsScrollViewInsets = true
        self.extendedLayoutIncludesOpaqueBars = false
        self.navigationItem.titleView = UIImageView(image: R.image.img_etologo())
        configRightNavButton(R.image.ic_records_24_px())
    }

    override func rightAction(_ sender: UIButton) {
        if !UserManager.shared.isLoginIn {
            appCoodinator.showLogin()
            return
        }
        self.coordinator?.openProjectHistroy()
    }

    func setupData() {
        self.view.showNoData("")
        self.startLoading()
    }

    func fetchProjectData() {
        self.coordinator?.fetchProjectData()
    }

    func fetchBannder() {
        self.coordinator?.fetchBannersData()
    }

    func setupEvent() {

    }

    override func configureObserveState() {
        coordinator?.state.pageState.asObservable().subscribe(onNext: {(_) in
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.data.asObservable().subscribe(onNext: { [weak self](data) in
            guard let `self` = self else { return }
            self.endLoading()
            self.view.hiddenNoData()
            self.homeView.data = data

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.bannerUrls.asObservable().subscribe(onNext: { [weak self](banners) in
            guard let `self` = self else { return }
            self.endLoading()
            guard let data = banners else { return }
            self.homeView.pageView.adapterModelToETOHomeBannerView(data)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension ETOViewController {
    @objc func ETOProjectViewDidClicked(_ data: [String: Any]) {
        if let viewModel = data["data"] as? ETOProjectViewModel {
            self.coordinator?.setSelectedProjectData(viewModel)
        }
    }

    @objc func ETOHomeBannerViewDidClicked(_ data: [String: Any]) {
        if let models = self.coordinator?.state.banners.value, let index = data["data"] as? Int, models.count >= index {
            self.coordinator?.setSelectedBannerData(models[index])
        }
    }
}
