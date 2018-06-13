//
//  BaseNavigationController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

class BaseNavigationController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme1BgColor = UIColor.dark
    self.view.theme2BgColor = UIColor.paleGrey

    self.interactivePopGestureRecognizer?.delegate = self
    let image = UIImage.init(color: .dark)
    self.navigationBar.setBackgroundImage(image, for: .default)
    self.navigationBar.shadowImage = UIImage()
    
    self.navigationBar.isTranslucent = false
    self.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:UIColor.paleGrey]
    if #available(iOS 11.0, *) {
      self.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:#colorLiteral(red: 1, green: 0.6386402845, blue: 0.3285836577, alpha: 1)]
    }
    self.navigationBar.tintColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)

//    self.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "ic_arrow_back_16px")
//    self.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "ic_arrow_back_16px")
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else { return }
      
      if ThemeManager.currentThemeIndex == 0 {
        let image = UIImage.init(color: UIColor.dark)
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:UIColor.paleGrey]
        self.navigationBar.setBackgroundImage(image, for: .default)

      }
      else {
        let image = UIImage.init(color:UIColor.paleGrey)
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:UIColor.dark]
        self.navigationBar.setBackgroundImage(image, for: .default)

      }
    })
    
  }
  
  
  
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    if self.viewControllers.count != 0 {
      viewController.hidesBottomBarWhenPushed = true
      super.pushViewController(viewController, animated: true)
      viewController.hidesBottomBarWhenPushed = false
    }
    else {
      super.pushViewController(viewController, animated: true)
    }
  }
  
  override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
    if self.childViewControllers.count == 2 {
      let vc = self.childViewControllers[1]
      vc.hidesBottomBarWhenPushed = false
    } else {
      let count = self.childViewControllers.count - 2
      let vc = self.childViewControllers[count]
      vc.hidesBottomBarWhenPushed = true
    }
    return super.popToViewController(viewController, animated: animated)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
  }
}

extension BaseNavigationController: UIGestureRecognizerDelegate{
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    // Ignore interactive pop gesture when there is only one view controller on the navigation stack
    if viewControllers.count <= 1 {
      return false
    }
    return true
  }
}
