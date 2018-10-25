//
//  BeareadToastAnimator.swift
//  BeareadToast
//
//  Created by Archy on 2017/12/19.
//  Copyright © 2017年 Archy. All rights reserved.
//

import Foundation
import UIKit

public protocol BeareadToastAnimatorDelegate {
    func show(completion:@escaping (Bool) -> Void)
    func hide(completion:@escaping (Bool) -> Void)
    func isShowing() -> Bool
    func isAnimating() -> Bool
}

public class BeareadToastAnimator: NSObject {
    
    fileprivate var isShow: Bool = false
    fileprivate var isAnimate: Bool = false
    public weak var toast: BeareadToast?
    public var animationType: ToastAnimationType = .slide
    
    init(toast: BeareadToast) {
        self.toast = toast
        super.init()
    }
}

extension BeareadToastAnimator : BeareadToastAnimatorDelegate {
    public func show(completion: @escaping (Bool) -> Void) {
        isShow = true
        isAnimate = true
        toast?.alpha = 1
        if animationType == .fade {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.toast?.contentView.alpha = 1
            },  completion: { (finished) in
                self.isAnimate = false
                completion(finished)
            })
        }
        else if animationType == .zoom {
            toast?.contentView.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.toast?.contentView.alpha = 1
                self.toast?.contentView.layer.transform = CATransform3DIdentity
            }, completion: { (finished) in
                self.isAnimate = false
                completion(finished)
            })
        }
        else if animationType == .slide {
            toast?.contentView.frame = CGRect.init(x: (toast?.contentView.frame.origin.x)!, y: (toast?.contentView.frame.origin.y)! - 20, width: (toast?.contentView.frame.size.width)!, height: (toast?.contentView.frame.size.height)!)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.toast?.contentView.alpha = 1
                self.toast?.contentView.frame = CGRect.init(x: (self.toast?.contentView.frame.origin.x)!, y: 10, width: (self.toast?.contentView.frame.size.width)!, height: (self.toast?.contentView.frame.size.height)!)
            }, completion: { (finished) in
                self.isAnimate = false
                completion(finished)
            })
        }
    }
    
    public func hide(completion: @escaping (Bool) -> Void) {
        isShow = false
        isAnimate = true
        if animationType == .fade {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.toast?.alpha = 0
            },  completion: { (finished) in
                self.isAnimate = false
                completion(finished)
            })
        }
        else if animationType == .zoom {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.toast?.contentView.alpha = 0
                self.toast?.contentView.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
            }, completion: { (finished) in
                self.isAnimate = false
                self.toast?.contentView.layer.transform = CATransform3DIdentity
                completion(finished)
            })
        }
        else if animationType == .slide {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.toast?.contentView.alpha = 0
                self.toast?.contentView.frame = CGRect.init(x: (self.toast?.contentView.frame.origin.x)!, y: (self.toast?.contentView.frame.origin.y)! - 20, width: (self.toast?.contentView.frame.size.width)!, height: (self.toast?.contentView.frame.size.height)!)
            }, completion: { (finished) in
                self.isAnimate = false
                completion(finished)
            })
        }
    }
    
    public func isShowing() -> Bool {
        return isShow
    }
    
    public func isAnimating() -> Bool {
        return isAnimate
    }
}
