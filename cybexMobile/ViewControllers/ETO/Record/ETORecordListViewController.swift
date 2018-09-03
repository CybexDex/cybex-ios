//
//  ETORecordListViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class ETORecordListViewController: BaseViewController {
    
    @IBOutlet weak var recordTableView: UITableView!
    var coordinator: (ETORecordListCoordinatorProtocol & ETORecordListStateManagerProtocol)?
    
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
        self.title = R.string.localizable.eto_records.key.localized()

        let nibString = R.nib.etoRecordCell.identifier
        recordTableView.register(UINib.init(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
        recordTableView.separatorStyle = .none
    }
    
    func setupData() {
        
    }
    
    func setupEvent() {
        
    }
    
    override func configureObserveState() {
        
    }
}

extension ETORecordListViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibString = String.init(describing:type(of: ETORecordCell()))
        let cell = tableView.dequeueReusableCell(withIdentifier: nibString, for: indexPath) as! ETORecordCell
        return cell
    }
}



extension ETORecordListViewController {
//    @objc func <#view#>DidClicked(_ data:[String: Any]) {
//        if let addressdata = data["data"] as? <#model#>, let view = data["self"] as? <#view#>  {
//
//        }
//    }
}

