//
//  ScanViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/10.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class ScanViewController: BaseViewController {
    let scanResult = Delegate<String, Void>()

    lazy var preView: ScanPreviewView = {
        let preView = ScanPreviewView.init(frame: self.view.bounds)
        return preView
    }()

    lazy var titleLabel: UILabel = {
        let rect = ScanSetting.scanRect
        let label = UILabel(frame: CGRect(x: 0, y: rect.maxY + 29, width: self.view.width, height: 20))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = subTitle
        return label
    }()

    var subTitle: String = R.string.localizable.scan_qrcode_hint()
    var captusession: AVCaptureSession?
    var viewSize: CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewSize = self.view.bounds.size
        self.view.addSubview(titleLabel)
        checkCameraAuth()
    }

    func checkCameraAuth() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) {[weak self] (_) in
                    guard let `self` = self else { return }
                    self.loadScanView()
                }
            } else if status == .authorized {
                self.loadScanView()
            } else { // 请授权
                self.loadScanView()
            }
        } else { //不支持camera
            self.loadScanView()
        }
    }

    func loadScanView() {
        startLoading()
        initSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setupPreviewLayer() {
        preView.session = captusession
        self.view.layer.insertSublayer(preView.layer, at: 0)
    }

    func initSession() {
        DispatchQueue.global().async {
            let session = AVCaptureSession()
            session.sessionPreset = .high
            self.addInput(session)
            self.addOutput(session, size: self.viewSize)
            session.startRunning()

            DispatchQueue.main.async {
                self.captusession = session
                self.setupPreviewLayer()
                self.endLoading()
            }
        }

    }

    func addInput(_ session: AVCaptureSession) {
        if let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                try session.addInput(AVCaptureDeviceInput.init(device: captureDevice))
            } catch let error as NSError {
                Log.print(error)
            }
        }
    }

    func addOutput(_ session: AVCaptureSession, size: CGSize) {
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)

            let rect = ScanSetting.scanRect
            output.rectOfInterest = CGRect(x: rect.origin.y / size.height,
                                           y: rect.origin.x / size.width,
                                           width: rect.size.height / size.height,
                                           height: rect.size.width / size.width)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
            output.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
        }
    }

}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let obj: AVMetadataMachineReadableCodeObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
                let result = obj.stringValue {
                scanResult.call(result)

                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
