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

class ETODetailViewController: BaseViewController {

	var coordinator: (ETODetailCoordinatorProtocol & ETODetailStateManagerProtocol)?

    @IBOutlet weak var contentView: ETODetailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.setupUI()
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        self.localized_text = R.string.localizable.eto_project_detail.key.localizedContainer()
        configRightNavButton(R.image.ic_share_24_px())
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openShare()
    }

    func setupData() {
        
    }
    
    func setupEvent() {
        
    }
    
    override func configureObserveState() {
        coordinator?.state.pageState.asObservable().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}


extension ETODetailViewController {
    @objc func clickCellView(_ data: [String: Any]) {
        
    }
    
    @objc func crowdPage(_ data : [String:Any]) {
        self.coordinator?.openETOCrowdVC()
    }
}
