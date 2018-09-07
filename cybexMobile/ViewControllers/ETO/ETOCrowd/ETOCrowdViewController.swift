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

class ETOCrowdViewController: BaseViewController {

	var coordinator: (ETOCrowdCoordinatorProtocol & ETOCrowdStateManagerProtocol)?

    @IBOutlet var contentView: ETOCrowdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        
    }

    func setupData() {
        self.coordinator?.fetchData()
        self.coordinator?.fetchUserRecord()
    }
    
    func setupEvent() {
        
    }
    
    override func configureObserveState() {
        coordinator?.state.pageState.asObservable().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        coordinator?.state.data.asObservable().subscribe(onNext: {[weak self] (model) in
            guard let `self` = self, let model = model else { return }

            self.contentView.updateUI(model, handler: ETOCrowdView.adapterModelToETOCrowdView(self.contentView))
        }).disposed(by: disposeBag)
        
        coordinator?.state.userData.asObservable().subscribe(onNext: {[weak self] (model) in
            guard let `self` = self, let model = model, let project = self.coordinator?.state.data.value else { return }
            
            self.contentView.updateUI((projectModel:project, userModel:model), handler: ETOCrowdView.adapterModelToUserCrowdView(self.contentView))
        }).disposed(by: disposeBag)
    }
}

//MARK: - TableViewDelegate

//extension ETOCrowdViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//          let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.<#cell#>.name, for: indexPath) as! <#cell#>
//
//        return cell
//    }
//}


//MARK: - View Event

//extension ETOCrowdViewController {
//    @objc func <#view#>DidClicked(_ data:[String: Any]) {
//        if let addressdata = data["data"] as? <#model#>, let view = data["self"] as? <#view#>  {
//
//        }
//    }
//}

