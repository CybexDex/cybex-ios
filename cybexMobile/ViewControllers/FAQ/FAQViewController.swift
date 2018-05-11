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
    
    let url = Defaults[.theme] == 0 ? "https://cybex.io/token_applications/new?style=night" : "https://cybex.io/token_applications/new"
    self.url = URL(string: url)
    
    super.viewDidLoad()

    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
    }
    
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else { return }
      if ThemeManager.currentThemeIndex == 0 {
        self.url = URL(string: "https://cybex.io/token_applications/new?style=night")
      } else {
        self.url = URL(string: "https://cybex.io/token_applications/new")
      }
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
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
  }
}
