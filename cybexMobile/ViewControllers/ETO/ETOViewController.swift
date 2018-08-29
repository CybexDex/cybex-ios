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

class ETOViewController: BaseViewController {
    
    var coordinator: (ETOCoordinatorProtocol & ETOStateManagerProtocol)?
    
    @IBOutlet weak var homeView: ETOHomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transferNavigationBar(0.0)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        configRightNavButton(R.image.ic_records_24_px())
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = true
        transferNavigationBar(0.0)
    }
    
    override func rightAction(_ sender: UIButton) {
       
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
    
    func transferNavigationBar(_ alpha : Double) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:UIColor.paleGrey]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.clear

    }
}

extension ETOViewController {
    @objc func ETOProjectViewDidClicked(_ data:[String: Any]) {
        if let addressdata = data["data"] as? ETOProjectModel, let view = data["self"] as? ETOProjectView  {
            self.coordinator?.openProjectItem()
        }
    }
}



