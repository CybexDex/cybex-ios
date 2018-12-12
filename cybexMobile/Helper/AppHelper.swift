//
//  AppHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

func openPage(_ urlString: String) {
    if let url = urlString.url {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

func saveImageToPhotos() {
    guard let window = UIApplication.shared.keyWindow else { return }

    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)

    window.layer.render(in: UIGraphicsGetCurrentContext()!)

    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
}
