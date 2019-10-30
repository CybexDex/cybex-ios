//
//  HashLockupAssetsViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/8/12.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import Reusable
import coswift

class HashLockupAssetsViewController: BaseViewController, StoryboardSceneBased {
    static var sceneStoryboard = UIStoryboard(name: "Account", bundle: nil)

    @IBOutlet weak var tableView: UITableView!

    var list: [Htlc] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = R.string.localizable.hashlockupAssetsTitle.key.localized()
        tableView.register(cellType: HashLockupAssetsTableViewCell.self)

        startLoading()
        fetchData()
    }

    func fetchData() {
        guard let name = UserManager.shared.name.value, let id = UserManager.shared.getCachedAccount()?.id else {
            endLoading()
            return
        }
        UserHelper.shared.cachedIdToName[id] = name
        CybexDatabaseApiService.request(target: .getAccount(name: name), success: { (data) in
            self.list = data[0][1]["htlcs"].arrayValue.map({ (d) -> Htlc? in
                do {
                    let m = try Htlc(data: JSONSerialization.data(withJSONObject: d.object, options: []))
                    return m

                } catch let error {
                    print(error)
                    return nil
                }
            }).compactMap({$0})

            co_launch {
                for (index, item) in self.list.enumerated() {
                    let waitFromResult = try await {
                       UserHelper.shared.getName(id: item.transfer.from)
                    }

                    if item.transfer.assetId.assetInfo == nil {
                        let _ = try await {
                            AssetHelper.shared.getAsset(id: item.transfer.assetId)
                        }
                    }

                    if case let .fulfilled(result) = waitFromResult {
                        self.list[index].from = result
                    }

                    let waitToResult = try await {
                        UserHelper.shared.getName(id: item.transfer.to)
                    }

                    if case let .fulfilled(result) = waitToResult {
                        self.list[index].to = result
                    }

                }

                self.endLoading()
                self.tableView.reloadData()
            }


        }, error: { (data) in

        }) { (error) in

        }
    }

    
}

extension HashLockupAssetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HashLockupAssetsTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        cell.setUpData(data: self.list[indexPath.row])
        return cell
    }


}
