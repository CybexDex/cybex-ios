//
//  PickerView.swift
//  cybexMobile
//
//  Created by peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

struct PickerData {
  static let key = "key"
  static let items = "items"
}

class PickerView: UIView {
  @IBOutlet weak var picker: UIPickerView!
  
  var selectedValues: [Int: Int]?
  
  var components: Int = 0
  
  open var items: AnyObject? {
    didSet {
      selectedValues = [Int: Int]()
      components = 0
      picker.reloadAllComponents()
    }
  }
  open func selectRow(_ row: Int, inComponent component: Int) {
    selectedValues![component] = row
    picker.selectRow(row, inComponent: component, animated: true)
  }
  
  fileprivate func setup() {
    picker.centerY(to: self,offset: 0)
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  fileprivate func updateHeight() {
    layoutIfNeeded()
    self.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  fileprivate func dynamicHeight() -> CGFloat {
    let lastView = self.subviews.last?.subviews.last
    return lastView!.bottom
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadViewFromNib()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadViewFromNib()
    setup()
  }
  
  fileprivate func loadViewFromNib() {
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
}

extension PickerView: UIPickerViewDelegate,UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    if items != nil {
      return self.numberOfComponents()
    }
    return 0
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if items != nil {
      return self.numberOfRowsInComponent(component)
    }
    return 0
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    if items != nil {
      if let title = self.titleForRow(row, component: component) {
        return NSAttributedString(string: title, attributes:[NSAttributedStringKey.foregroundColor: ThemeManager.currentThemeIndex == 0 ? pickerView.theme1TintColor : pickerView.theme2TintColor])
      }
    }
    return nil
  }
  
}

extension PickerView {
  
  func numberOfComponents() -> Int {
    if items is [String] {
      return 1
    }
    if items is [[String]] {
      return (items as! [[String]]).count
    }
    if let items = self.items as? [Int: AnyObject] {
      if components == 0 {
        var obj:AnyObject? = items[0]
        while obj != nil {
          components += 1
          if obj is [Int: AnyObject] {
            obj = (obj as! [Int: AnyObject])[0]
          }
          if obj is [String: AnyObject] {
            obj = (obj as! [String: AnyObject])[PickerData.items]
          }
          if obj is [String] {
            components += 1
            break
          }
        }
      }
      return components
    }
    return 0
  }
  
  func numberOfRowsInComponent(_ component: Int) -> Int {
    if items is [String] {
      return (items as! [String]).count
    }
    if let items = self.items as? [[String]] {
      let components:Int = items.count
      if components > 0 && component < components {
        let items:[String] = items[component]
        return items.count
      }
    }
    if let items = self.items as? [Int: [String: AnyObject]] {
      var c: Int = 0
      var obj: AnyObject? = items as AnyObject?
      if c < component {
        while c < component && obj != nil {
          obj = (obj as! [Int: [String: AnyObject]])[picker.selectedRow(inComponent: c)] as AnyObject?
          if obj is [String: AnyObject] {
            obj = (obj as! [String: AnyObject])[PickerData.items]
          }
          c += 1
        }
      }
      if c == component {
        if obj is [String] {
          return (obj as! [String]).count
        }
        if obj is [Int: [String: AnyObject]] {
          return (obj as! [Int: [String: AnyObject]]).keys.count
        }
      }
    }
    return 0
  }
  
  func titleForRow(_ row: Int, component: Int) -> String? {
    if items is [String] {
      return (items as! [String])[row]
    }
    if let items = self.items as? [[String]] {
      var items: [String] = items[component]
      return items[row]
    }
    if let items = self.items as? [Int: [String: AnyObject]] {
      var c: Int = 0
      var obj: AnyObject? = items as AnyObject?
      if c < component {
        while c < component && obj != nil {
          obj = (obj as! [Int: [String: AnyObject]])[picker.selectedRow(inComponent: c)] as AnyObject?
          if obj is [String: AnyObject] {
            obj = (obj as! [String: AnyObject])["items"]
          }
          c += 1
        }
      }
      if c == component {
        if obj is [String] {
          if row < (obj as! [String]).count {
            return (obj as! [String])[row]
          }
        }
        else if obj is [Int: [String: AnyObject]] {
          let d: [Int: [String: AnyObject]] = (obj as! [Int: [String: AnyObject]])
          let d1: [String: AnyObject] = d[row]! as [String: AnyObject]
          return d1[PickerData.key] as? String
        }
      }
    }
    return nil
  }
}
