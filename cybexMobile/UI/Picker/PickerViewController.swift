//
//  PickerViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

typealias OnPickerComfirm = () -> Void

class PickerViewController: BaseViewController {

    var coordinator: (PickerCoordinatorProtocol & PickerStateManagerProtocol)?
    private(set) var context: PickerContext?

    var onPickerComfirm: OnPickerComfirm?

    @IBOutlet weak var pickerView: PickerView!

    var items: AnyObject?

    var selectedValue: (component: NSInteger, row: NSInteger) = (0, 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        self.configRightNavButton(R.string.localizable.picker_comfirm.key.decapitalized())
        if let items = items {
            pickerView.items = items
            pickerView.selectRow(selectedValue.component, inComponent: selectedValue.row)
        }
    }

    override func rightAction(_ sender: UIButton) {
        self.coordinator?.finishWithPicker(pickerView.picker)
    }

    override func configureObserveState() {
        self.coordinator?.state.context.asObservable().subscribe(onNext: { [weak self] (context) in
            guard let `self` = self else { return }

            if let context = context as? PickerContext {
                self.context = context
                self.selectedValue = context.selectedValue
                self.items = context.items
                if let items = self.items {
                    self.pickerView.items = items
                    self.pickerView.selectRow(self.selectedValue.component, inComponent: self.selectedValue.row)
                }
            }
        }).disposed(by: disposeBag)
    }
}
