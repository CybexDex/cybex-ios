//
//  SettingViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift
import SwiftTheme
import SwiftyUserDefaults
import EZSwiftExtensions

class SettingViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!

	var coordinator: (SettingCoordinatorProtocol & SettingStateManagerProtocol)?

	override func viewDidLoad() {
    super.viewDidLoad()
    
    self.localized_text = R.string.localizable.navSetting.key.localizedContainer()
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
    }

    self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, w: self.tableView.bounds.size.width, h: 0.01))

    setupNotification()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

  }
  
  func setupNotification() {
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else { return }
     
      self.tableView.reloadData()
    })
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else { return }
      
      self.tableView.reloadData()
      let color = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
      self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: color), for: .default)
    })

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
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
  }
}


extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: SettingCell.self), for: indexPath) as! SettingCell
    cell.layer.cornerRadius = 4
    cell.layer.masksToBounds = true
    cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "ic_arrow_forward_16px"))
    
    if (indexPath.section == 1) {
      cell.textLabel?.localized_text = R.string.localizable.theme.key.localizedContainer()
      cell.detailTextLabel?.localized_text = ThemeManager.currentThemeIndex == 0 ? R.string.localizable.dark.key.localizedContainer() : R.string.localizable.light.key.localizedContainer()
    }
    else if indexPath.section == 0 {
      cell.textLabel?.localized_text = R.string.localizable.language.key.localizedContainer()
      cell.detailTextLabel?.text = Localize.currentLanguage() == "en" ? "English" : "简体中文"
    }
    else {
      cell.textLabel?.localized_text = R.string.localizable.version.key.localizedContainer()
      cell.detailTextLabel?.text = ez.appVersion!
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // test
    if indexPath.section == 1 {
      self.coordinator?.openAccount()
    }else if indexPath.section == 2{
      self.coordinator?.openLockupAssets()
    }else{
      self.coordinator?.openYourProtfolio()
    }
    return
    
    if indexPath.section == 2 {
      self.startLoading()
      handlerUpdateVersion({
        self.endLoading()
      }, showNoUpdate: true)
      return
    }
    
    self.coordinator?.openSettingDetail(type: indexPath.section == 0 ? .language : .theme)
   
  }

}
