//  This file was automatically generated and should not be edited.

import Apollo

public final class VerifyAddressQuery: GraphQLQuery {
  public static let operationString =
  "query VerifyAddress($asset: String!, $address: String!, $accountName: String) {\n  verifyAddress(asset: $asset, address: $address, accountName: $accountName) {\n    __typename\n    ...WithdrawAddressInfo\n  }\n}"
  
  public static var requestString: String { return operationString.appending(WithdrawAddressInfo.fragmentString) }
  
  public var asset: String
  public var address: String
  public var accountName: String?
  
  public init(asset: String, address: String, accountName: String? = nil) {
    self.asset = asset
    self.address = address
    self.accountName = accountName
  }
  
  public var variables: GraphQLMap? {
    return ["asset": asset, "address": address, "accountName": accountName]
  }
  
  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]
    
    public static let selections: [GraphQLSelection] = [
      GraphQLField("verifyAddress", arguments: ["asset": GraphQLVariable("asset"), "address": GraphQLVariable("address"), "accountName": GraphQLVariable("accountName")], type: .nonNull(.object(VerifyAddress.selections))),
      ]
    
    public var snapshot: Snapshot
    
    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }
    
    public init(verifyAddress: VerifyAddress) {
      self.init(snapshot: ["__typename": "Query", "verifyAddress": verifyAddress.snapshot])
    }
    
    public var verifyAddress: VerifyAddress {
      get {
        return VerifyAddress(snapshot: snapshot["verifyAddress"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "verifyAddress")
      }
    }
    
    public struct VerifyAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["WithdrawAddressInfo"]
      
      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("asset", type: .scalar(String.self)),
        GraphQLField("valid", type: .nonNull(.scalar(Bool.self))),
        ]
      
      public var snapshot: Snapshot
      
      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }
      
      public init(address: String, asset: String? = nil, valid: Bool) {
        self.init(snapshot: ["__typename": "WithdrawAddressInfo", "address": address, "asset": asset, "valid": valid])
      }
      
      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }
      
      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }
      
      public var asset: String? {
        get {
          return snapshot["asset"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "asset")
        }
      }
      
      public var valid: Bool {
        get {
          return snapshot["valid"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "valid")
        }
      }
      
      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
      
      public struct Fragments {
        public var snapshot: Snapshot
        
        public var withdrawAddressInfo: WithdrawAddressInfo {
          get {
            return WithdrawAddressInfo(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetWithdrawInfoQuery: GraphQLQuery {
  public static let operationString =
  "query GetWithdrawInfo($type: String!) {\n  withdrawInfo(type: $type) {\n    __typename\n    ...WithdrawinfoObject\n  }\n}"
  
  public static var requestString: String { return operationString.appending(WithdrawinfoObject.fragmentString) }
  
  public var type: String
  
  public init(type: String) {
    self.type = type
  }
  
  public var variables: GraphQLMap? {
    return ["type": type]
  }
  
  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]
    
    public static let selections: [GraphQLSelection] = [
      GraphQLField("withdrawInfo", arguments: ["type": GraphQLVariable("type")], type: .nonNull(.object(WithdrawInfo.selections))),
      ]
    
    public var snapshot: Snapshot
    
    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }
    
    public init(withdrawInfo: WithdrawInfo) {
      self.init(snapshot: ["__typename": "Query", "withdrawInfo": withdrawInfo.snapshot])
    }
    
    public var withdrawInfo: WithdrawInfo {
      get {
        return WithdrawInfo(snapshot: snapshot["withdrawInfo"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "withdrawInfo")
      }
    }
    
    public struct WithdrawInfo: GraphQLSelectionSet {
      public static let possibleTypes = ["WithdrawInfo"]
      
      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("minValue", type: .nonNull(.scalar(Double.self))),
        GraphQLField("fee", type: .nonNull(.scalar(Double.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("asset", type: .nonNull(.scalar(String.self))),
        GraphQLField("gatewayAccount", type: .nonNull(.scalar(String.self))),
        GraphQLField("precision", type: .scalar(Int.self)),
        ]
      
      public var snapshot: Snapshot
      
      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }
      
      public init(minValue: Double, fee: Double, type: String, asset: String, gatewayAccount: String, precision: Int? = nil) {
        self.init(snapshot: ["__typename": "WithdrawInfo", "minValue": minValue, "fee": fee, "type": type, "asset": asset, "gatewayAccount": gatewayAccount, "precision": precision])
      }
      
      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }
      
      public var minValue: Double {
        get {
          return snapshot["minValue"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "minValue")
        }
      }
      
      public var fee: Double {
        get {
          return snapshot["fee"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "fee")
        }
      }
      
      public var type: String {
        get {
          return snapshot["type"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }
      
      public var asset: String {
        get {
          return snapshot["asset"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "asset")
        }
      }
      
      public var gatewayAccount: String {
        get {
          return snapshot["gatewayAccount"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "gatewayAccount")
        }
      }
      
      public var precision: Int? {
        get {
          return snapshot["precision"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "precision")
        }
      }
      
      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
      
      public struct Fragments {
        public var snapshot: Snapshot
        
        public var withdrawinfoObject: WithdrawinfoObject {
          get {
            return WithdrawinfoObject(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetDepositAddressQuery: GraphQLQuery {
  public static let operationString =
  "query GetDepositAddress($accountName: String!, $asset: String) {\n  getDepositAddress(accountName: $accountName, asset: $asset) {\n    __typename\n    ...accountAddressRecord\n  }\n}"
  
  public static var requestString: String { return operationString.appending(AccountAddressRecord.fragmentString) }
  
  public var accountName: String
  public var asset: String?
  
  public init(accountName: String, asset: String? = nil) {
    self.accountName = accountName
    self.asset = asset
  }
  
  public var variables: GraphQLMap? {
    return ["accountName": accountName, "asset": asset]
  }
  
  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]
    
    public static let selections: [GraphQLSelection] = [
      GraphQLField("getDepositAddress", arguments: ["accountName": GraphQLVariable("accountName"), "asset": GraphQLVariable("asset")], type: .object(GetDepositAddress.selections)),
      ]
    
    public var snapshot: Snapshot
    
    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }
    
    public init(getDepositAddress: GetDepositAddress? = nil) {
      self.init(snapshot: ["__typename": "Query", "getDepositAddress": getDepositAddress.flatMap { (value: GetDepositAddress) -> Snapshot in value.snapshot }])
    }
    
    public var getDepositAddress: GetDepositAddress? {
      get {
        return (snapshot["getDepositAddress"] as? Snapshot).flatMap { GetDepositAddress(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getDepositAddress")
      }
    }
    
    public struct GetDepositAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["AccountAddressRecord"]
      
      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("accountName", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("asset", type: .nonNull(.scalar(String.self))),
        GraphQLField("jadeOrders", type: .nonNull(.list(.scalar(String.self)))),
        GraphQLField("latest", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createAt", type: .scalar(String.self)),
        ]
      
      public var snapshot: Snapshot
      
      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }
      
      public init(accountName: String, address: String, type: String? = nil, asset: String, jadeOrders: [String?], latest: Bool, createAt: String? = nil) {
        self.init(snapshot: ["__typename": "AccountAddressRecord", "accountName": accountName, "address": address, "type": type, "asset": asset, "jadeOrders": jadeOrders, "latest": latest, "createAt": createAt])
      }
      
      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }
      
      public var accountName: String {
        get {
          return snapshot["accountName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accountName")
        }
      }
      
      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }
      
      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }
      
      public var asset: String {
        get {
          return snapshot["asset"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "asset")
        }
      }
      
      public var jadeOrders: [String?] {
        get {
          return snapshot["jadeOrders"]! as! [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "jadeOrders")
        }
      }
      
      public var latest: Bool {
        get {
          return snapshot["latest"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "latest")
        }
      }
      
      public var createAt: String? {
        get {
          return snapshot["createAt"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createAt")
        }
      }
      
      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
      
      public struct Fragments {
        public var snapshot: Snapshot
        
        public var accountAddressRecord: AccountAddressRecord {
          get {
            return AccountAddressRecord(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class NewDepositAddressMutation: GraphQLMutation {
  public static let operationString =
  "mutation NewDepositAddress($accountName: String!, $asset: String!) {\n  newDepositAddress(accountName: $accountName, asset: $asset) {\n    __typename\n    ...accountAddressRecord\n  }\n}"
  
  public static var requestString: String { return operationString.appending(AccountAddressRecord.fragmentString) }
  
  public var accountName: String
  public var asset: String
  
  public init(accountName: String, asset: String) {
    self.accountName = accountName
    self.asset = asset
  }
  
  public var variables: GraphQLMap? {
    return ["accountName": accountName, "asset": asset]
  }
  
  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]
    
    public static let selections: [GraphQLSelection] = [
      GraphQLField("newDepositAddress", arguments: ["accountName": GraphQLVariable("accountName"), "asset": GraphQLVariable("asset")], type: .nonNull(.object(NewDepositAddress.selections))),
      ]
    
    public var snapshot: Snapshot
    
    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }
    
    public init(newDepositAddress: NewDepositAddress) {
      self.init(snapshot: ["__typename": "Mutation", "newDepositAddress": newDepositAddress.snapshot])
    }
    
    public var newDepositAddress: NewDepositAddress {
      get {
        return NewDepositAddress(snapshot: snapshot["newDepositAddress"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "newDepositAddress")
      }
    }
    
    public struct NewDepositAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["AccountAddressRecord"]
      
      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("accountName", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("asset", type: .nonNull(.scalar(String.self))),
        GraphQLField("jadeOrders", type: .nonNull(.list(.scalar(String.self)))),
        GraphQLField("latest", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createAt", type: .scalar(String.self)),
        ]
      
      public var snapshot: Snapshot
      
      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }
      
      public init(accountName: String, address: String, type: String? = nil, asset: String, jadeOrders: [String?], latest: Bool, createAt: String? = nil) {
        self.init(snapshot: ["__typename": "AccountAddressRecord", "accountName": accountName, "address": address, "type": type, "asset": asset, "jadeOrders": jadeOrders, "latest": latest, "createAt": createAt])
      }
      
      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }
      
      public var accountName: String {
        get {
          return snapshot["accountName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accountName")
        }
      }
      
      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }
      
      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }
      
      public var asset: String {
        get {
          return snapshot["asset"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "asset")
        }
      }
      
      public var jadeOrders: [String?] {
        get {
          return snapshot["jadeOrders"]! as! [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "jadeOrders")
        }
      }
      
      public var latest: Bool {
        get {
          return snapshot["latest"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "latest")
        }
      }
      
      public var createAt: String? {
        get {
          return snapshot["createAt"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createAt")
        }
      }
      
      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
      
      public struct Fragments {
        public var snapshot: Snapshot
        
        public var accountAddressRecord: AccountAddressRecord {
          get {
            return AccountAddressRecord(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public struct WithdrawAddressInfo: GraphQLFragment {
  public static let fragmentString =
  "fragment WithdrawAddressInfo on WithdrawAddressInfo {\n  __typename\n  address\n  asset\n  valid\n}"
  
  public static let possibleTypes = ["WithdrawAddressInfo"]
  
  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("address", type: .nonNull(.scalar(String.self))),
    GraphQLField("asset", type: .scalar(String.self)),
    GraphQLField("valid", type: .nonNull(.scalar(Bool.self))),
    ]
  
  public var snapshot: Snapshot
  
  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }
  
  public init(address: String, asset: String? = nil, valid: Bool) {
    self.init(snapshot: ["__typename": "WithdrawAddressInfo", "address": address, "asset": asset, "valid": valid])
  }
  
  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }
  
  public var address: String {
    get {
      return snapshot["address"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "address")
    }
  }
  
  public var asset: String? {
    get {
      return snapshot["asset"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "asset")
    }
  }
  
  public var valid: Bool {
    get {
      return snapshot["valid"]! as! Bool
    }
    set {
      snapshot.updateValue(newValue, forKey: "valid")
    }
  }
}

public struct WithdrawinfoObject: GraphQLFragment {
  public static let fragmentString =
  "fragment WithdrawinfoObject on WithdrawInfo {\n  __typename\n  minValue\n  fee\n  type\n  asset\n  gatewayAccount\n  precision\n}"
  
  public static let possibleTypes = ["WithdrawInfo"]
  
  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("minValue", type: .nonNull(.scalar(Double.self))),
    GraphQLField("fee", type: .nonNull(.scalar(Double.self))),
    GraphQLField("type", type: .nonNull(.scalar(String.self))),
    GraphQLField("asset", type: .nonNull(.scalar(String.self))),
    GraphQLField("gatewayAccount", type: .nonNull(.scalar(String.self))),
    GraphQLField("precision", type: .scalar(Int.self)),
    ]
  
  public var snapshot: Snapshot
  
  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }
  
  public init(minValue: Double, fee: Double, type: String, asset: String, gatewayAccount: String, precision: Int? = nil) {
    self.init(snapshot: ["__typename": "WithdrawInfo", "minValue": minValue, "fee": fee, "type": type, "asset": asset, "gatewayAccount": gatewayAccount, "precision": precision])
  }
  
  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }
  
  public var minValue: Double {
    get {
      return snapshot["minValue"]! as! Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "minValue")
    }
  }
  
  public var fee: Double {
    get {
      return snapshot["fee"]! as! Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "fee")
    }
  }
  
  public var type: String {
    get {
      return snapshot["type"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "type")
    }
  }
  
  public var asset: String {
    get {
      return snapshot["asset"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "asset")
    }
  }
  
  public var gatewayAccount: String {
    get {
      return snapshot["gatewayAccount"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "gatewayAccount")
    }
  }
  
  public var precision: Int? {
    get {
      return snapshot["precision"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "precision")
    }
  }
}

public struct AccountAddressRecord: GraphQLFragment {
  public static let fragmentString =
  "fragment accountAddressRecord on AccountAddressRecord {\n  __typename\n  accountName\n  address\n  type\n  asset\n  jadeOrders\n  latest\n  createAt\n}"
  
  public static let possibleTypes = ["AccountAddressRecord"]
  
  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("accountName", type: .nonNull(.scalar(String.self))),
    GraphQLField("address", type: .nonNull(.scalar(String.self))),
    GraphQLField("type", type: .scalar(String.self)),
    GraphQLField("asset", type: .nonNull(.scalar(String.self))),
    GraphQLField("jadeOrders", type: .nonNull(.list(.scalar(String.self)))),
    GraphQLField("latest", type: .nonNull(.scalar(Bool.self))),
    GraphQLField("createAt", type: .scalar(String.self)),
    ]
  
  public var snapshot: Snapshot
  
  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }
  
  public init(accountName: String, address: String, type: String? = nil, asset: String, jadeOrders: [String?], latest: Bool, createAt: String? = nil) {
    self.init(snapshot: ["__typename": "AccountAddressRecord", "accountName": accountName, "address": address, "type": type, "asset": asset, "jadeOrders": jadeOrders, "latest": latest, "createAt": createAt])
  }
  
  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }
  
  public var accountName: String {
    get {
      return snapshot["accountName"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "accountName")
    }
  }
  
  public var address: String {
    get {
      return snapshot["address"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "address")
    }
  }
  
  public var type: String? {
    get {
      return snapshot["type"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "type")
    }
  }
  
  public var asset: String {
    get {
      return snapshot["asset"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "asset")
    }
  }
  
  public var jadeOrders: [String?] {
    get {
      return snapshot["jadeOrders"]! as! [String?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "jadeOrders")
    }
  }
  
  public var latest: Bool {
    get {
      return snapshot["latest"]! as! Bool
    }
    set {
      snapshot.updateValue(newValue, forKey: "latest")
    }
  }
  
  public var createAt: String? {
    get {
      return snapshot["createAt"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "createAt")
    }
  }
}
