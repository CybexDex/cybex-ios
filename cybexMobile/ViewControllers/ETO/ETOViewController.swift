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

class ETOViewController: BaseViewController {
    
    var coordinator: (ETOCoordinatorProtocol & ETOStateManagerProtocol)?
    @IBOutlet weak var homeView: ETOHomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        setupEvent()
    }

    override func refreshViewController() {
        
    }
    
    func setupUI() {
        setupNaviUI()
    }
    
    func setupNaviUI() {
        self.navigationItem.titleView = UIImageView(image: R.image.img_etologo())
        configRightNavButton(R.image.ic_records_24_px())
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openProjectHistroy()
    }
    
    func setupData() {
        fetchData()
        fetchBannder()
    }
    
    func fetchData() {
        
    }
    
    func fetchBannder() {
        
    }
    
    func setupEvent() {
   
    }
    
    override func configureObserveState() {
        coordinator?.state.pageState.asObservable().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        coordinator?.state.data.asObservable().subscribe(onNext: { [weak self](data) in
            guard let `self` = self else { return }
            self.endLoading()
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        coordinator?.state.banners.asObservable().subscribe(onNext: { [weak self](banners) in
            guard let `self` = self else { return }
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension ETOViewController {
    @objc func ETOProjectViewDidClicked(_ data:[String: Any]) {
        self.coordinator?.openProjectItem()
    }
    
    @objc func ETOHomeBannerViewDidClicked(_ data:[String:Any]) {
        self.coordinator?.openBanner()
    }
}



