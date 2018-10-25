//
//  ViewController.swift
//  BeareadToast
//
//  Created by Archy on 2017/12/19.
//  Copyright © 2017年 Archy. All rights reserved.
//

import UIKit
import BeareadToast_swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func succeedAction(_ sender: UIButton) {
        let _ = BeareadToast.showSucceed(text: "Success", inView: view, hide: 2)
    }
    @IBAction func errorAction(_ sender: UIButton) {
        let _ = BeareadToast.showError(text: "Error", inView: view, hide: 2)
    }
    @IBAction func loadingAction(_ sender: UIButton) {
        let _ = BeareadToast.showLoading(inView: view)
    }
    @IBAction func textAction(_ sender: UIButton) {
        let _ = BeareadToast.showText(text: "Test Message", inView: view, hide: 2)
    }
    
}

