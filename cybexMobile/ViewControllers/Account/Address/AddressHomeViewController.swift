//
//  AddressHomeViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class AddressHomeViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var coordinator: (AddressHomeCoordinatorProtocol & AddressHomeStateManagerProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        self.localizedText = R.string.localizable.address_manager.key.localizedContainer()
        
        self.tableView.register(UINib(resource: R.nib.addressHomeTableViewCell), forCellReuseIdentifier: R.nib.addressHomeTableViewCell.name)
    }
    
    override func configureObserveState() {
        
    }
}

extension AddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.addressHomeTableViewCell.name, for: indexPath) as? AddressHomeTableViewCell {
            return cell
        }
        return AddressHomeTableViewCell()
    }
}

extension AddressHomeViewController {
    @objc func clickCellView(_ data: [String: Any]) {
        if let index = data["index"] as? Int {
            switch index {
            case 0:
                self.coordinator?.openWithDrawAddressHomeViewController()
            case 1:
                self.coordinator?.openTransferAddressHomeViewController()
            default:
                break
            }
        }
    }
}
