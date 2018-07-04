//
//  MarketCache.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import GRDB

struct MarketRecord:Codable {
  var id: Int64?

  var base_volume: String
  var quote_volume: String
  
  
  var open:TimeInterval
}

extension MarketRecord:MutablePersistableRecord,FetchableRecord  {
  static var databaseTableName: String = "markets"
  
  mutating func didInsert(with rowID: Int64, for column: String?) {
    id = rowID
  }
}

class MarketCache: LocalCache {
  
  static let shared = MarketCache()
  
  private init() {
    super.init("db.sqlite")
  }
  
  override func createTable() throws {
    try queue?.write({ db in
      try db.create(table: MarketRecord.databaseTableName) { t in
        t.column("id", .integer).primaryKey()
        t.column("base_volume", .text).notNull()
        t.column("quote_volume", .text).notNull()
        t.column("open", .double).notNull().defaults(to: 0)
      }
    })
  }
  
  func insertRecord(record: MarketRecord) throws {
    var record = record
    
    try queue?.inDatabase({ db in
      try record.insert(db)
    })
  }
  
  func fetchAll() throws -> [MarketRecord]? {
    return try queue?.inDatabase({ db in
//      let base_volume = Column("base_volume")
      
      

      return try MarketRecord.fetchAll(db)
    })
  }
}

