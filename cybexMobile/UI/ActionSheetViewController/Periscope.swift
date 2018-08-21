//  Periscope.swift
//  Periscope ( https://github.com/xmartlabs/XLActionController )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import XLActionController

public class PeriscopeCell: XLActionController.ActionCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize() {
        let backgroundView = UIView()
        selectedBackgroundView = backgroundView
    }
}


public class PeriscopeSection: Section<String, Void> {
    public override init() {
        super.init()
        self.data = ()
    }
}

public class PeriscopeHeader: UICollectionReusableView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 120/255.0, green: 129/255.0, blue: 154/255.0, alpha: 1.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 16.0)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        addSubview(label)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class PeriscopeActionController: ActionController<PeriscopeCell, String, PeriscopeHeader, String, UICollectionReusableView, Void> {
    var tapMaskCallback:CommonCallback?

    var selectedIndex : IndexPath?
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        collectionViewLayout.minimumLineSpacing = -0.5
        collectionViewLayout.sectionInset = UIEdgeInsets(top: -0.5, left: 0, bottom: 0, right: 0)
        
        settings.behavior.hideOnScrollDown = false
        settings.animation.scale = nil
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.5
        settings.animation.dismiss.options = .curveEaseIn
        settings.animation.dismiss.offset = 30
        
        cellSpec = .nibFile(nibName: "PeriscopeCell", bundle: Bundle(for: PeriscopeCell.self), height: { _ in 60})
        sectionHeaderSpec = .cellClass(height: { _ in 12 })
        headerSpec = .cellClass(height: { [weak self] (headerData: String) in
            guard let me = self else { return 0 }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: me.view.frame.width - 40, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17.0)
            label.text = headerData
            label.sizeToFit()
            return label.frame.size.height + 20
        })
        
        onConfigureHeader = { [weak self] header, headerData in
            guard let me = self else { return }
            header.label.frame = CGRect(x: 0, y: 0, width: me.view.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude)
            header.label.text = headerData
            header.label.sizeToFit()
            header.label.center = CGPoint(x: header.frame.size.width  / 2, y:header.frame.size.height / 2)
        }
        onConfigureSectionHeader = { sectionHeader, sectionHeaderData in
            sectionHeader.backgroundColor = UIColor.clear
        }
        onConfigureCellForAction = { [weak self] cell, action, indexPath in
            guard let `self` = self else { return }
            cell.setup(action.data, detail: nil, image: nil)
            cell.separatorView?.isHidden = indexPath.item == self.collectionView.numberOfItems(inSection: indexPath.section) - 1
            if let selectedIndex = self.selectedIndex, selectedIndex == indexPath {
                cell.actionTitleLabel?.textColor = UIColor.pastelOrange
            }
        }
    }
    
    public override func onWillDismissView() {
        tapMaskCallback?()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? PeriscopeCell {
            cell.actionTitleLabel?.textColor = UIColor.pastelOrange
        }
    }
}

