//
//  LocalCache.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
//import GRDB
//import CryptoSwift
//
//class LocalCache {
//  private var sqliteName:String = "" //must be override
//  private var _queue:DatabaseQueue?
//  var migrator = DatabaseMigrator()
//  
//  let config = { () -> Configuration in
//    var conf = Configuration()
//    conf.trace = { print($0) }
//    return conf
//  }()
//  
//  var queue:DatabaseQueue? {
//    guard let path = checkDirIsExist() else {
//      return nil
//    }
//    
//    if let q = _queue {
//      return q
//    }
//    
//    let url = URL(string: path)!.appendingPathComponent(sqliteName)
//    
//    
//    
//    let dbQueue = try? DatabaseQueue(path: url.path, configuration:config)
//    _queue = dbQueue
//    
//    try? createTable()
//    migration()
//    
//    return _queue
//  }
//  
//  init(_ name : String = "") {
//    sqliteName = name
//  }
//  
//  private func checkDirIsExist() -> String? {
//    //        guard UserModules.shared.isLogin else {
//    //            return nil
//    //        }
//    
//    let uid = "user".md5()
//    let libraryUrl = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//    let dbUrl = libraryUrl?.appendingPathComponent("db").appendingPathComponent("\(uid)")
//    
//    if let url = dbUrl, !FileManager.default.fileExists(atPath: url.path) {
//      do {
//        try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
//      } catch let error {
//        fatalError(error.localizedDescription)
//      }
//      
//    }
//    
//    return dbUrl?.path
//  }
//  
//  func createTable() throws {
//    fatalError("must be override")
//  }
//  
//  func migration() {
//    
//  }
//  
//  
//}
//
