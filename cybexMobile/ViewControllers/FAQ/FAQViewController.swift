//
//  FAQViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftTheme
import SwiftyUserDefaults

class FAQViewController: BaseWebViewController {

	var coordinator: (FAQCoordinatorProtocol & FAQStateManagerProtocol)?

	override func viewDidLoad() {
    
    let url = Defaults[.theme] == 0 ?AppConfiguration.FAQ_NIGHT_THEME : AppConfiguration.FAQ_LIGHT_THEME
    self.url = URL(string: url)
    
    super.viewDidLoad()

    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
    }
    
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else { return }
      if ThemeManager.currentThemeIndex == 0 {
        self.url = URL(string: AppConfiguration.FAQ_NIGHT_THEME)
      } else {
        self.url = URL(string: AppConfiguration.FAQ_LIGHT_THEME)
      }
    })
  }

  
  override func configureObserveState() {
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
  }
}
