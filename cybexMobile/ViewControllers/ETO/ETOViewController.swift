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

    @IBOutlet weak var pageView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var coordinator: (ETOCoordinatorProtocol & ETOStateManagerProtocol)?

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
        tableView.register(UINib.init(nibName: R.nib.etoProjectCell.name, bundle: nil), forCellReuseIdentifier: R.nib.etoProjectCell.name)
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

//MARK: - TableViewDelegate

extension ETOViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etoProjectCell.name, for: indexPath) as! ETOProjectCell

        return cell
    }
}


extension ETOViewController {
    @objc func ETOProjectViewDidClicked(_ data:[String: Any]) {
        if let addressdata = data["data"] as? ETOProjectModel, let view = data["self"] as? ETOProjectView  {

        }
    }
}

