//
//  OpenedOrdersViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class OpenedOrdersViewController: BaseViewController {
    @IBOutlet weak var segment: UISegmentedControl!
  
  @IBOutlet weak var tableView: UITableView!
  
	var coordinator: (OpenedOrdersCoordinatorProtocol & OpenedOrdersStateManagerProtocol)?
  
	override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
  
  func setupUI(){
    self.localized_text = R.string.localizable.openedTitle.key.localizedContainer()
    let cell = String.init(describing:OpenedOrdersCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
  }
  
    func commonObserveState() {
        coordinator?.subscribe(errorSubscriber) { sub in
            return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
                return false
            })
        }
        
        coordinator?.subscribe(loadingSubscriber) { sub in
            return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
                return false
            })
        }
    }
 
    
    override func configureObserveState() {
        commonObserveState()
        
    }
}

extension OpenedOrdersViewController : UITableViewDataSource,UITableViewDelegate{

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OpenedOrdersCell.self), for: indexPath) as! OpenedOrdersCell
    
    return cell
  }
  

  
}

extension OpenedOrdersViewController {
  @IBAction func segmentClicked(_ sender: Any) {
    
  }
}
