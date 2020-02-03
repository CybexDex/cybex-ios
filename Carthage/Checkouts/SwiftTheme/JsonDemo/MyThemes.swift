//
//  MyThemes.swift
//  JsonDemo
//
//  Created by Gesen on 16/3/14.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import Foundation
import SwiftTheme

enum MyThemes: Int {
    
    case red   = 0
    case yello = 1
    case blue  = 2
    case night = 3
    
    // MARK: -
    
    static var current = MyThemes.red
    static var before  = MyThemes.red
    
    // MARK: - Switch Theme
    
    static func switchTo(_ theme: MyThemes) {
        before  = current
        current = theme
        
        switch theme {
        case .red   : ThemeManager.setTheme(jsonName: "Red", path: .mainBundle)
        case .yello : ThemeManager.setTheme(jsonName: "Yellow", path: .mainBundle)
        case .blue  : ThemeManager.setTheme(jsonName: "Blue", path: .sandbox(blueDiretory))
        case .night : ThemeManager.setTheme(jsonName: "Night", path: .mainBundle)
        }
    }
    
    static func switchToNext() {
        var next = current.rawValue + 1
        var max  = 2 // without Blue and Night
        
        if isBlueThemeExist() { max += 1 }
        if next >= max { next = 0 }
        
        switchTo(MyThemes(rawValue: next)!)
    }
    
    // MARK: - Switch Night
    
    static func switchNight(_ isToNight: Bool) {
        switchTo(isToNight ? .night : before)
    }
    
    static func isNight() -> Bool {
        return current == .night
    }
    
    // MARK: - Download
    
    static func downloadBlueTask(_ handler: @escaping (_ isSuccess: Bool) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            guard let bundlePath = Bundle.main.url(forResource: "Blue", withExtension: "zip") else {
                DispatchQueue.main.async {
                    handler(false)
                }
                return
            }
            let manager = FileManager.default
            let zipPath = cachesURL.appendingPathComponent("Blue.zip")
            
            _ = try? manager.removeItem(at: zipPath)
            _ = try? manager.copyItem(at: bundlePath, to: zipPath)
            
            let isSuccess = SSZipArchive.unzipFile(atPath: zipPath.path,
                                        toDestination: unzipPath.path)
            
            DispatchQueue.main.async {
                handler(isSuccess)
            }
        }
    }
    
    static func isBlueThemeExist() -> Bool {
        return FileManager.default.fileExists(atPath: blueDiretory.path)
    }
    
    static let blueDiretory : URL = unzipPath.appendingPathComponent("Blue/")
    static let unzipPath    : URL = libraryURL.appendingPathComponent("Themes/20170128")
    
}
