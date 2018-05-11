//
//  DemoCache.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import GRDB

struct Place:Codable {
  var id: Int64?
  var title: String
  var isFavorite: Bool
}

extension Place:MutablePersistable,RowConvertible {
  static var databaseTableName: String = "places"
  
  
  mutating func didInsert(with rowID: Int64, for column: String?) {
    id = rowID
  }
}

class PlaceCache:LocalCache {
  static let shared = PlaceCache()
  
  private init() {
    super.init("db.sqlite")
  }
  
  override func createTable() throws {
    try queue?.write { db in
      try db.create(table: Place.databaseTableName) { t in
        t.column("id", .integer).primaryKey()
        t.column("title", .text).notNull()
        t.column("isFavorite", .boolean).notNull().defaults(to: false)
        t.column("test", .date).notNull().defaults(to: Date())
      }
    }
  }
  
  override func migration() {
    //添加字段
    migrator.registerMigration("AddDateToPlace") { db in
      do {
        
        try db.alter(table: Place.databaseTableName, body: {t in
          t.add(column: "date", .date).notNull().defaults(to: Date())
        })
      } catch let error {
        dump(error)
      }
    }
    //添加索引
    migrator.registerMigration("addfavIndex") { db in
      try? db.create(index: "byFav", on: Place.databaseTableName, columns: ["id", "isFavorite"], unique: true)
    }
    
    
    try? migrator.migrate(queue!)
  }
  
  func insertPlace(place:Place) throws {
    var place = place
    
    try queue?.inDatabase({ db in
      try place.insert(db)
    })
  }
  
  func fetchAllPlace() throws -> [Place]? {
    return try queue?.inDatabase({ db in
      try Place.fetchAll(db)
    })
  }
  
}
