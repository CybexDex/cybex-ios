//
//  Utils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

func calculateAssetRelation(assetID_A_name:String, assetID_B_name:String) -> (base:String, quote:String) {
  let relation:[String] = ["ETH", "BTC", "EOS", "CYB"]

  var indexA = -1
  var indexB = -1
  
  if let index = relation.index(of: assetID_A_name) {
    indexA = index
  }
  
  if let index = relation.index(of: assetID_B_name) {
    indexB = index
  }
  
  
  if indexA < indexB {
    return (assetID_A_name, assetID_B_name)
  }
  else if indexA > indexB {
    return (assetID_B_name, assetID_A_name)
  }
  else {
    if assetID_A_name < assetID_B_name {
      return (assetID_A_name, assetID_B_name)
    }
    else {
      return (assetID_B_name, assetID_A_name)
    }
  }
 
}
