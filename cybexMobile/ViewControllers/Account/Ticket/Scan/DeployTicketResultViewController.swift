//
//  DeployTicketResultViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/11.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import TangramKit
import Proposer
import EFQRCode
import RxSwift
import NotificationBanner

class DeployTicketResultViewController: BaseViewController {
    var assetName: String!
    var qrcodeInfo: String!

    var qrImageView: UIImageView!
    var transactionId:String!

    var banner: NotificationBanner?

    var bag: DisposeBag? = DisposeBag() {
        didSet {
            if bag == nil {
                self.banner = UIHelper.showSuccessTop("您的票已被成功使用！")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = R.string.localizable.ticket_use_title.key.localized() + " " + assetName
        setupUI()
        scanTransferStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.banner?.dismiss()
    }

    func setupUI() {
        let layout = TGLinearLayout(.vert)
        layout.tg_top ~= self.view.windowWithNavSafeAreaInsets.top
        layout.tg_width ~= self.view.width
        layout.tg_height ~= .wrap

        let imageView = UIImageView()
        imageView.image = generateQRCode(qrcodeInfo)
        imageView.tg_size(CGSize(width: 155, height: 155))
        imageView.tg_top ~= 23
        imageView.tg_centerX ~= 0
        layout.addSubview(imageView)
        qrImageView = imageView

        let button = UIButton()
        button.backgroundColor = .clear
        button.locali = R.string.localizable.deposit_save.key
        button.setTitleColor(UIColor.pastelOrange, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(saveButtonDidClicked), for: .touchUpInside)
        button.tg_top ~= 12
        button.tg_centerX ~= 0
        button.tg_width ~= .wrap
        button.tg_height ~= .wrap
        layout.addSubview(button)

        let view = TGLinearLayout(.vert)
        view.theme_backgroundColor = [UIColor.darkTwo.hexString(true), UIColor.white.hexString(true)]
        view.tg_left ~= 13
        view.tg_right ~= 13
        view.tg_top ~= 24
        view.tg_width ~= .fill
        view.tg_height ~= .wrap
        layout.addSubview(view)

        let label = BaseLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .steel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineHeight = 20
        label.tg_left ~= 4
        label.tg_right ~= 4
        label.tg_top ~= 12
        label.tg_bottom ~= 12
        label.tg_width ~= .fill
        label.tg_height ~= .wrap
        label.locali = R.string.localizable.ticket_deploy_result_info.key
        view.addSubview(label)

        self.view.addSubview(layout)
    }

    @objc func saveButtonDidClicked() {
        guard let image = qrImageView.image else { return }
        saveToGallery(image)
    }
}

// MARK: - Logic
extension DeployTicketResultViewController {
    func generateQRCode(_ content: String) -> UIImage? {
        let generator = EFQRCodeGenerator(content: content, size: EFIntSize(width: 155, height: 155))
        if let image = generator.generate() {
            return UIImage(cgImage: image)
        }

        return nil
    }

    func saveToGallery(_ image: UIImage) {
        let photos: PrivateResource = .photos
        proposeToAccess(photos, agreed: {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                self.showToastBox(true, message: R.string.localizable.recharge_save.key.localized())
            }
        }, rejected: {
            let message = R.string.localizable.tip_message.key.localized()

            self.showToastBox(false, message: message)
        })
    }

    func scanTransferStatus() {
        Observable<Int>.interval(1, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (num) in
            guard let self = self else { return }

            CybexDatabaseApiService.request(target: DatabaseApi.getRecentTransactionBy(self.transactionId), success: { (json) in
                if String(describing: json) != "null" {
                    self.bag = nil
                }

            }, error: { (error) in

            }, failure: { (error) in

            })

        }).disposed(by: self.bag!)
    }
}
