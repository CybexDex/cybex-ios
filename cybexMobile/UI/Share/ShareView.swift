//
//  ShareView.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ShareView: UIView {
    var maskColor: UIColor? = UIColor.darkTwo50 {
        didSet {
            if let shareMaskView = _maskView {
                shareMaskView.backgroundColor = maskColor
            }
        }
    }
    
    var contentColor: UIColor? = UIColor.white {
        didSet {
            if let contentView = contentView {
                contentView.backgroundColor = contentColor
            }
        }
    }
    
    var title: String? {
        didSet {
            
        }
    }
    
    var shareModes: ShareModes = [.wechat, .timeLine, .qq, .sina]
    
    var canTapClose = true
    
    var needAnimation = false
    
    var shareData: ShareData?
    
    fileprivate var _maskView: UIView?
    
    fileprivate var contentView: GridContentView?
    
    convenience public init () {
        self.init(frame:CGRect.zero)
    }
    
    func show() {
        self.showInView(UIApplication.shared.keyWindow!)
    }
    
    func showInView(_ view: UIView) {
        self.frame = view.bounds
        setupUI()
        view.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.contentView?.frame.origin.y = self.frame.size.height - (self.contentView?.frame.size.height)!
        }
    }
    
    func close() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView?.frame.origin.y = self.frame.size.height
        }) { (success) in
            if success {
                UIView.animate(withDuration: 0.3, animations: {
                    self._maskView?.alpha = 0
                }, completion: { (success) in
                    if self._maskView != nil {
                        self._maskView?.removeFromSuperview()
                        self._maskView = nil
                    }
                    self.removeFromSuperview()
                })
            }
        }
    }
    
    func shareType() -> ShareType {
        if let data = shareData {
            if data.isKind(of: ShareWebData.self) {
                return ShareType.web
            } else if data.isKind(of: ShareImageData.self) {
                return ShareType.image
            }
        }
        return ShareType.none
    }
    
    func setupUI() {
        if _maskView == nil {
            _maskView = UIView(frame: self.bounds)
            _maskView?.backgroundColor = maskColor
            self.addSubview(_maskView!)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapMaskView))
            _maskView?.addGestureRecognizer(tap)
        }
        
        if contentView == nil {
            var rect = self.bounds
            rect.origin.y = self.bounds.size.height
            rect.size.height = 0
            contentView = GridContentView(frame: rect)
            contentView?.delegate = self
            contentView?.datasource = self
            contentView?.backgroundColor = self.contentColor
            contentView?.reloadData()
            self.addSubview(contentView!)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    func shareItemViews() -> [UIView] {
        var views: [UIView] = []
        if shareModes.contains(.wechat) {
            views.append(viewWithImgName(R.image.ic_wechat_48_px.name))
        }
        if shareModes.contains(.timeLine) {
            views.append(viewWithImgName(R.image.ic_moments_48_px.name))
        }
        if shareModes.contains(.qq) {
            views.append(viewWithImgName(R.image.ic_qq_48_px.name))
        }
        if shareModes.contains(.sina) {
            views.append(viewWithImgName(R.image.ic_webo_48_px.name))
        }
        return views
    }
    
    func viewWithImgName(_ name: String) -> UIImageView {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFit
        view.image = UIImage.init(named: name)
        return view
    }
    
    @objc fileprivate func tapMaskView() {
        if canTapClose {
            self.close()
        }
    }
    
}

extension ShareView: GridContentViewDelegate,GridContentViewDataSource {
    func itemSizeForView(_ view: GridContentView) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func itemDidSelect(_ view: GridContentView, index: NSInteger) {
        
    }
    
    func itemsForView(_ view: GridContentView) -> [UIView] {
        return shareItemViews()
    }
    
    func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 3
    }
    
    func edgeInsetsForView(_ view: GridContentView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(30, 25, 30, 25)
    }
    
}

