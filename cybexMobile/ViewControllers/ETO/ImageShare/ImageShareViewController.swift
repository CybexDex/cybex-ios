//
//  ImageShareViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Kingfisher

class ImageShareViewController: BaseViewController {

    @IBOutlet weak var imgContentView: UIImageView!

    var coordinator: (ImageShareCoordinatorProtocol & ImageShareStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func refreshViewController() {

    }

    func setupUI() {
        if let url = URL(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535699127775&di=9b05e71fe836bd1e8482a4699e9f4249&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201512%2F28%2F20151228084800_axmt5.jpeg") {
            imgContentView.kf.setImage(with: url)
        }

        let shareView = ShareView()
        shareView.maskColor = UIColor.clear
        shareView.contentColor = UIColor.darkTwo80
        shareView.canTapClose = false
        shareView.showInView(self.view)
    }

    func setupData() {

    }

    func setupEvent() {

    }

    override func configureObserveState() {

    }
}

// MARK: - TableViewDelegate

//extension ImageShareViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//          let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.<#cell#>.name, for: indexPath) as! <#cell#>
//
//        return cell
//    }
//}

// MARK: - View Event

//extension ImageShareViewController {
//    @objc func <#view#>DidClicked(_ data:[String: Any]) {
//        if let addressdata = data["data"] as? <#model#>, let view = data["self"] as? <#view#>  {
//
//        }
//    }
//}
