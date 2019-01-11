//
//  ScanPreviewView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/17.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import AVFoundation

class ScanPreviewView: UIView {

    lazy var shadeView: ScanShadeView = {
        let shadeView = ScanShadeView.init(frame: self.bounds)
        return shadeView
    }()

    var session: AVCaptureSession? {
        didSet {
            guard let layer = self.layer as? AVCaptureVideoPreviewLayer else {
                return
            }
            layer.videoGravity = .resizeAspectFill
            layer.session = session
        }
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.backgroundColor = UIColor.clear
        self.addSubview(shadeView)
    }

}
