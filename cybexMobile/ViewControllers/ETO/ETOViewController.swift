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
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        self.localized_text = R.string.localizable.hot_project.key.localizedContainer()
        configRightNavButton(R.image.ic_records_24_px())
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in
            guard let `self` = self else { return }
            self.homeView.fetchAlphaProgress()
        })
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
    
    func transferNavigationBar(_ alpha : CGFloat) {
        self.navigationController?.navigationBar.isTranslucent = alpha > 0.9 ? false : true
        if ThemeManager.currentThemeIndex == 0 {
            let image = UIImage.init(color: UIColor.dark.withAlphaComponent(alpha))
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:UIColor.paleGrey.withAlphaComponent(alpha)]
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        }
        else {
            let image = UIImage.init(color:UIColor.paleGrey.withAlphaComponent(alpha))
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:UIColor.dark.withAlphaComponent(alpha)]
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        }
    }
}

extension ETOViewController {
    @objc func ETOProjectViewDidClicked(_ data:[String: Any]) {
        self.coordinator?.openProjectItem()
    }
    
    @objc func ChangeNavigationBarEvent(_ data:[String:Any]) {
        if let progress = data["progress"] as? CGFloat {
            self.transferNavigationBar(progress)
        }
    }
}



