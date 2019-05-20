//
//  SettingDetailViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/2.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import Localize_Swift
import SwiftyUserDefaults
import SwifterSwift

enum SettingPage {
    case language
    case theme
}

class SettingDetailViewController: BaseViewController {
    
    var pageType: SettingPage = .language
    
    @IBOutlet weak var tableView: UITableView!
    
    var coordinator: (SettingDetailCoordinatorProtocol & SettingDetailStateManagerProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizedText = self.pageType == .language ? R.string.localizable.language.key.localizedContainer() : R.string.localizable.theme.key.localizedContainer()
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 0.01))
        self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top + 10, left: 0, bottom: 0, right: 0)
    }
    
    override func configureObserveState() {
        
    }
}

extension SettingDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: SettingCell.self), for: indexPath) as? SettingCell else {
            return SettingCell()
        }
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "ic_check_active_circle_24px"))
        
        switch self.pageType {
        case SettingPage.theme:
            if (indexPath.row == 0) {
                cell.textLabel?.localizedText = R.string.localizable.dark.key.localizedContainer()
            } else {
                cell.textLabel?.localizedText = R.string.localizable.light.key.localizedContainer()
            }
            
            cell.textLabel?.isHighlighted = ThemeManager.currentThemeIndex == indexPath.row
        case SettingPage.language:
            cell.textLabel?.text = ["English", "简体中文"][indexPath.row]
            
            if indexPath.row == 0 && Localize.currentLanguage() == "en" {
                cell.textLabel?.isHighlighted = true
            } else if indexPath.row == 1 && Localize.currentLanguage() == "zh-Hans" {
                cell.textLabel?.isHighlighted = true
            } else {
                cell.textLabel?.isHighlighted = false
            }
        }
        
        cell.accessoryView?.isHidden = !cell.textLabel!.isHighlighted
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index  = indexPath.row
        
        switch self.pageType {
        case SettingPage.theme:
            self.coordinator?.popViewController(false)
            delay(milliseconds: 10) {
                Defaults[.theme] = index
                ThemeManager.setTheme(index: index)
            }
            
        case SettingPage.language:
            self.coordinator?.popViewController(false)
            delay(milliseconds: 10) {
                let language = index == 1 ? "zh-Hans" : "en"
                Defaults[.language] = language
                Localize.setCurrentLanguage(language)
            }
        }
    }
}
