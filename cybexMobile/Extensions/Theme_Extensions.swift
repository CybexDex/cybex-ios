//
//  Theme_Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

extension UILabel {

  @IBInspectable
  var theme1TitleColor: UIColor {
    set {
      if let theme2 = self.store["label_theme2"] as? String {
        theme_textColor = [newValue.hexString(true), theme2]
      } else {
        self.store["label_theme1"] = newValue.hexString(true)
      }
    }

    get {
      return theme_textColor?.value() as! UIColor
    }
  }

  var themeTitleColor: UIColor {
    return theme_textColor?.value() as! UIColor
  }

  @IBInspectable
  var theme2TitleColor: UIColor {
    set {
      if let theme1 = self.store["label_theme1"] as? String {
        theme_textColor = [theme1, newValue.hexString(true)]
      } else {
        self.store["label_theme2"] = newValue.hexString(true)
      }
    }

    get {
      return theme_textColor?.value() as! UIColor
    }
  }
}

extension UITextView {
  @IBInspectable
  var theme1TitleColor: UIColor {
    set {
      if let theme2 = self.store["label_theme2"] as? String {
        theme_textColor = [newValue.hexString(true), theme2]
      } else {
        self.store["label_theme1"] = newValue.hexString(true)
      }
    }

    get {
      return theme_textColor?.value() as! UIColor
    }
  }

  var themeTitleColor: UIColor {
    return theme_textColor?.value() as! UIColor
  }

  @IBInspectable
  var theme2TitleColor: UIColor {
    set {
      if let theme1 = self.store["label_theme1"] as? String {
        theme_textColor = [theme1, newValue.hexString(true)]
      } else {
        self.store["label_theme2"] = newValue.hexString(true)
      }
    }

    get {
      return theme_textColor?.value() as! UIColor
    }
  }
}

extension UIImageView {
  @IBInspectable
  var theme1ImageName: String {
    set {
      if let theme2 = self.store["image_theme2"] as? String {
        theme_image = [newValue, theme2]
      } else {
        self.store["image_theme1"] = newValue
      }
    }

    get {
      return theme_image?.value() as! String
    }
  }

  @IBInspectable
  var theme2ImageName: String {
    set {
      if let theme1 = self.store["image_theme1"] as? String {
        theme_image = [theme1, newValue]
      } else {
        self.store["image_theme2"] = newValue
      }
    }

    get {
      return theme_image?.value() as! String
    }
  }
}

extension UITextField {
  @IBInspectable
  var theme1TitleColor: UIColor {
    set {
      if let theme2 = self.store["label_theme2"] as? String {
        theme_textColor = [newValue.hexString(true), theme2]
      } else {
        self.store["label_theme1"] = newValue.hexString(true)
      }
    }

    get {
      return theme_textColor?.value() as! UIColor
    }
  }

  var themeTitleColor: UIColor {
    return theme_textColor?.value() as! UIColor
  }

  @IBInspectable
  var theme2TitleColor: UIColor {
    set {
      if let theme1 = self.store["label_theme1"] as? String {
        theme_textColor = [theme1, newValue.hexString(true)]
      } else {
        self.store["label_theme2"] = newValue.hexString(true)
      }
    }

    get {
      return theme_textColor?.value() as! UIColor
    }
  }
}

extension UIView {
    @IBInspectable
    var theme1ShadowColor: UIColor {
        set {
            if let theme2 = self.store["shadow_theme2"] as? String {
                layer.theme_shadowColor = [newValue.hexString(true), theme2]
            } else {
                self.store["shadow_theme1"] = newValue.hexString(true)
            }
        }

        get {
            return layer.theme_shadowColor?.value() as! UIColor
        }
    }

    @IBInspectable
    var theme2ShadowColor: UIColor {
        set {
            if let theme1 = self.store["shadow_theme1"] as? String {
                layer.theme_shadowColor = [theme1, newValue.hexString(true)]
            } else {
                self.store["shadow_theme2"] = newValue.hexString(true)
            }
        }

        get {
            return layer.theme_shadowColor?.value() as! UIColor
        }
    }
}

extension UIView {
  @IBInspectable
  var theme1BgColor: UIColor {
    set {
      if let theme2 = self.store["bg_theme2"] as? String {
        theme_backgroundColor = [newValue.hexString(true), theme2]
      } else {
        self.store["bg_theme1"] = newValue.hexString(true)
      }
    }

    get {
      return theme_backgroundColor?.value() as! UIColor
    }
  }

  @IBInspectable
  var theme2BgColor: UIColor {
    set {
      if let theme1 = self.store["bg_theme1"] as? String {
        theme_backgroundColor = [theme1, newValue.hexString(true)]
      } else {
        self.store["bg_theme2"] = newValue.hexString(true)
      }
    }

    get {
      return theme_backgroundColor?.value() as! UIColor
    }
  }

  var themeBgColor: UIColor {
    return theme_backgroundColor?.value() as! UIColor
  }
}

extension UIPickerView {
  @IBInspectable
  var theme1TintColor: UIColor {
    set {
      if let theme2 = self.store["picker_theme2"] as? String {
        theme_tintColor = [newValue.hexString(true), theme2]
      } else {
        self.store["picker_theme1"] = newValue.hexString(true)
      }
    }

    get {
      return theme_tintColor?.value() as! UIColor
    }
  }

  var themeTintColor: UIColor {
    return theme_tintColor?.value() as! UIColor
  }

  @IBInspectable
  var theme2TintColor: UIColor {
    set {
      if let theme1 = self.store["picker_theme1"] as? String {
        theme_tintColor = [theme1, newValue.hexString(true)]
      } else {
        self.store["picker_theme2"] = newValue.hexString(true)
      }
    }

    get {
      return theme_tintColor?.value() as! UIColor
    }
  }
}
