//  This file was automatically generated and should not be edited.

import Apollo

public final class VerifyAddressQuery: GraphQLQuery {
  public let operationDefinition =
    "query VerifyAddress($asset: String!, $address: String!, $accountName: String) {\n  verifyAddress(asset: $asset, address: $address, accountName: $accountName) {\n    __typename\n    ...WithdrawAddressInfo\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(WithdrawAddressInfo.fragmentDefinition) }

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
      GraphQLField("verifyAddress", arguments: ["asset": GraphQLVariable("asset"), "address": GraphQLVariable("address"), "accountName": GraphQLVariable("accountName")], type: .nonNull(.object(VerifyAddress.selections)))
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(verifyAddress: VerifyAddress) {
      self.init(unsafeResultMap: ["__typename": "Query", "verifyAddress": verifyAddress.resultMap])
    }

    public var verifyAddress: VerifyAddress {
      get {
        return VerifyAddress(unsafeResultMap: resultMap["verifyAddress"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "verifyAddress")
      }
    }

    public struct VerifyAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["WithdrawAddressInfo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("asset", type: .scalar(String.self)),
        GraphQLField("valid", type: .nonNull(.scalar(Bool.self)))
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(address: String, asset: String? = nil, valid: Bool) {
        self.init(unsafeResultMap: ["__typename": "WithdrawAddressInfo", "address": address, "asset": asset, "valid": valid])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var address: String {
        get {
          return resultMap["address"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "address")
        }
      }

      public var asset: String? {
        get {
          return resultMap["asset"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "asset")
        }
      }

      public var valid: Bool {
        get {
          return resultMap["valid"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "valid")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var withdrawAddressInfo: WithdrawAddressInfo {
          get {
            return WithdrawAddressInfo(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetWithdrawInfoQuery: GraphQLQuery {
  public let operationDefinition =
    "query GetWithdrawInfo($type: String!) {\n  withdrawInfo(type: $type) {\n    __typename\n    ...WithdrawinfoObject\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(WithdrawinfoObject.fragmentDefinition) }

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
      GraphQLField("withdrawInfo", arguments: ["type": GraphQLVariable("type")], type: .nonNull(.object(WithdrawInfo.selections)))
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(withdrawInfo: WithdrawInfo) {
      self.init(unsafeResultMap: ["__typename": "Query", "withdrawInfo": withdrawInfo.resultMap])
    }

    public var withdrawInfo: WithdrawInfo {
      get {
        return WithdrawInfo(unsafeResultMap: resultMap["withdrawInfo"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "withdrawInfo")
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
        GraphQLField("precision", type: .scalar(Int.self))
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(minValue: Double, fee: Double, type: String, asset: String, gatewayAccount: String, precision: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "WithdrawInfo", "minValue": minValue, "fee": fee, "type": type, "asset": asset, "gatewayAccount": gatewayAccount, "precision": precision])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var minValue: Double {
        get {
          return resultMap["minValue"]! as! Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "minValue")
        }
      }

      public var fee: Double {
        get {
          return resultMap["fee"]! as! Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "fee")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var asset: String {
        get {
          return resultMap["asset"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "asset")
        }
      }

      public var gatewayAccount: String {
        get {
          return resultMap["gatewayAccount"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "gatewayAccount")
        }
      }

      public var precision: Int? {
        get {
          return resultMap["precision"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "precision")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var withdrawinfoObject: WithdrawinfoObject {
          get {
            return WithdrawinfoObject(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetDepositAddressQuery: GraphQLQuery {
  public let operationDefinition =
    "query GetDepositAddress($accountName: String!, $asset: String) {\n  getDepositAddress(accountName: $accountName, asset: $asset) {\n    __typename\n    ...accountAddressRecord\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(AccountAddressRecord.fragmentDefinition) }

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
      GraphQLField("getDepositAddress", arguments: ["accountName": GraphQLVariable("accountName"), "asset": GraphQLVariable("asset")], type: .object(GetDepositAddress.selections))
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getDepositAddress: GetDepositAddress? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getDepositAddress": getDepositAddress.flatMap { (value: GetDepositAddress) -> ResultMap in value.resultMap }])
    }

    public var getDepositAddress: GetDepositAddress? {
      get {
        return (resultMap["getDepositAddress"] as? ResultMap).flatMap { GetDepositAddress(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getDepositAddress")
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
        GraphQLField("projectInfo", type: .object(ProjectInfo.selections))
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(accountName: String, address: String, type: String? = nil, asset: String, jadeOrders: [String?], latest: Bool, createAt: String? = nil, projectInfo: ProjectInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "AccountAddressRecord", "accountName": accountName, "address": address, "type": type, "asset": asset, "jadeOrders": jadeOrders, "latest": latest, "createAt": createAt, "projectInfo": projectInfo.flatMap { (value: ProjectInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var accountName: String {
        get {
          return resultMap["accountName"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "accountName")
        }
      }

      public var address: String {
        get {
          return resultMap["address"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "address")
        }
      }

      public var type: String? {
        get {
          return resultMap["type"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var asset: String {
        get {
          return resultMap["asset"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "asset")
        }
      }

      public var jadeOrders: [String?] {
        get {
          return resultMap["jadeOrders"]! as! [String?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "jadeOrders")
        }
      }

      public var latest: Bool {
        get {
          return resultMap["latest"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "latest")
        }
      }

      public var createAt: String? {
        get {
          return resultMap["createAt"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "createAt")
        }
      }

      public var projectInfo: ProjectInfo? {
        get {
          return (resultMap["projectInfo"] as? ResultMap).flatMap { ProjectInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "projectInfo")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var accountAddressRecord: AccountAddressRecord {
          get {
            return AccountAddressRecord(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct ProjectInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["ProjectInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("projectName", type: .scalar(String.self)),
          GraphQLField("logoUrl", type: .scalar(String.self)),
          GraphQLField("contractAddress", type: .scalar(String.self)),
          GraphQLField("contractExplorerUrl", type: .scalar(String.self))
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(projectName: String? = nil, logoUrl: String? = nil, contractAddress: String? = nil, contractExplorerUrl: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "ProjectInfo", "projectName": projectName, "logoUrl": logoUrl, "contractAddress": contractAddress, "contractExplorerUrl": contractExplorerUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var projectName: String? {
          get {
            return resultMap["projectName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "projectName")
          }
        }

        public var logoUrl: String? {
          get {
            return resultMap["logoUrl"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "logoUrl")
          }
        }

        public var contractAddress: String? {
          get {
            return resultMap["contractAddress"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "contractAddress")
          }
        }

        public var contractExplorerUrl: String? {
          get {
            return resultMap["contractExplorerUrl"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "contractExplorerUrl")
          }
        }
      }
    }
  }
}

public final class NewDepositAddressMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation NewDepositAddress($accountName: String!, $asset: String!) {\n  newDepositAddress(accountName: $accountName, asset: $asset) {\n    __typename\n    ...accountAddressRecord\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(AccountAddressRecord.fragmentDefinition) }

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
      GraphQLField("newDepositAddress", arguments: ["accountName": GraphQLVariable("accountName"), "asset": GraphQLVariable("asset")], type: .nonNull(.object(NewDepositAddress.selections)))
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(newDepositAddress: NewDepositAddress) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "newDepositAddress": newDepositAddress.resultMap])
    }

    public var newDepositAddress: NewDepositAddress {
      get {
        return NewDepositAddress(unsafeResultMap: resultMap["newDepositAddress"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "newDepositAddress")
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
        GraphQLField("projectInfo", type: .object(ProjectInfo.selections))
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(accountName: String, address: String, type: String? = nil, asset: String, jadeOrders: [String?], latest: Bool, createAt: String? = nil, projectInfo: ProjectInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "AccountAddressRecord", "accountName": accountName, "address": address, "type": type, "asset": asset, "jadeOrders": jadeOrders, "latest": latest, "createAt": createAt, "projectInfo": projectInfo.flatMap { (value: ProjectInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var accountName: String {
        get {
          return resultMap["accountName"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "accountName")
        }
      }

      public var address: String {
        get {
          return resultMap["address"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "address")
        }
      }

      public var type: String? {
        get {
          return resultMap["type"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var asset: String {
        get {
          return resultMap["asset"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "asset")
        }
      }

      public var jadeOrders: [String?] {
        get {
          return resultMap["jadeOrders"]! as! [String?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "jadeOrders")
        }
      }

      public var latest: Bool {
        get {
          return resultMap["latest"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "latest")
        }
      }

      public var createAt: String? {
        get {
          return resultMap["createAt"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "createAt")
        }
      }

      public var projectInfo: ProjectInfo? {
        get {
          return (resultMap["projectInfo"] as? ResultMap).flatMap { ProjectInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "projectInfo")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var accountAddressRecord: AccountAddressRecord {
          get {
            return AccountAddressRecord(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct ProjectInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["ProjectInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("projectName", type: .scalar(String.self)),
          GraphQLField("logoUrl", type: .scalar(String.self)),
          GraphQLField("contractAddress", type: .scalar(String.self)),
          GraphQLField("contractExplorerUrl", type: .scalar(String.self))
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(projectName: String? = nil, logoUrl: String? = nil, contractAddress: String? = nil, contractExplorerUrl: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "ProjectInfo", "projectName": projectName, "logoUrl": logoUrl, "contractAddress": contractAddress, "contractExplorerUrl": contractExplorerUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var projectName: String? {
          get {
            return resultMap["projectName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "projectName")
          }
        }

        public var logoUrl: String? {
          get {
            return resultMap["logoUrl"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "logoUrl")
          }
        }

        public var contractAddress: String? {
          get {
            return resultMap["contractAddress"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "contractAddress")
          }
        }

        public var contractExplorerUrl: String? {
          get {
            return resultMap["contractExplorerUrl"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "contractExplorerUrl")
          }
        }
      }
    }
  }
}

public struct WithdrawAddressInfo: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment WithdrawAddressInfo on WithdrawAddressInfo {\n  __typename\n  address\n  asset\n  valid\n}"

  public static let possibleTypes = ["WithdrawAddressInfo"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("address", type: .nonNull(.scalar(String.self))),
    GraphQLField("asset", type: .scalar(String.self)),
    GraphQLField("valid", type: .nonNull(.scalar(Bool.self)))
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(address: String, asset: String? = nil, valid: Bool) {
    self.init(unsafeResultMap: ["__typename": "WithdrawAddressInfo", "address": address, "asset": asset, "valid": valid])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var address: String {
    get {
      return resultMap["address"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "address")
    }
  }

  public var asset: String? {
    get {
      return resultMap["asset"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "asset")
    }
  }

  public var valid: Bool {
    get {
      return resultMap["valid"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "valid")
    }
  }
}

public struct WithdrawinfoObject: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment WithdrawinfoObject on WithdrawInfo {\n  __typename\n  minValue\n  fee\n  type\n  asset\n  gatewayAccount\n  precision\n}"

  public static let possibleTypes = ["WithdrawInfo"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("minValue", type: .nonNull(.scalar(Double.self))),
    GraphQLField("fee", type: .nonNull(.scalar(Double.self))),
    GraphQLField("type", type: .nonNull(.scalar(String.self))),
    GraphQLField("asset", type: .nonNull(.scalar(String.self))),
    GraphQLField("gatewayAccount", type: .nonNull(.scalar(String.self))),
    GraphQLField("precision", type: .scalar(Int.self))
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(minValue: Double, fee: Double, type: String, asset: String, gatewayAccount: String, precision: Int? = nil) {
    self.init(unsafeResultMap: ["__typename": "WithdrawInfo", "minValue": minValue, "fee": fee, "type": type, "asset": asset, "gatewayAccount": gatewayAccount, "precision": precision])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var minValue: Double {
    get {
      return resultMap["minValue"]! as! Double
    }
    set {
      resultMap.updateValue(newValue, forKey: "minValue")
    }
  }

  public var fee: Double {
    get {
      return resultMap["fee"]! as! Double
    }
    set {
      resultMap.updateValue(newValue, forKey: "fee")
    }
  }

  public var type: String {
    get {
      return resultMap["type"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "type")
    }
  }

  public var asset: String {
    get {
      return resultMap["asset"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "asset")
    }
  }

  public var gatewayAccount: String {
    get {
      return resultMap["gatewayAccount"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "gatewayAccount")
    }
  }

  public var precision: Int? {
    get {
      return resultMap["precision"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "precision")
    }
  }
}

public struct AccountAddressRecord: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment accountAddressRecord on AccountAddressRecord {\n  __typename\n  accountName\n  address\n  type\n  asset\n  jadeOrders\n  latest\n  createAt\n  projectInfo {\n    __typename\n    projectName\n    logoUrl\n    contractAddress\n    contractExplorerUrl\n  }\n}"

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
    GraphQLField("projectInfo", type: .object(ProjectInfo.selections))
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(accountName: String, address: String, type: String? = nil, asset: String, jadeOrders: [String?], latest: Bool, createAt: String? = nil, projectInfo: ProjectInfo? = nil) {
    self.init(unsafeResultMap: ["__typename": "AccountAddressRecord", "accountName": accountName, "address": address, "type": type, "asset": asset, "jadeOrders": jadeOrders, "latest": latest, "createAt": createAt, "projectInfo": projectInfo.flatMap { (value: ProjectInfo) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var accountName: String {
    get {
      return resultMap["accountName"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "accountName")
    }
  }

  public var address: String {
    get {
      return resultMap["address"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "address")
    }
  }

  public var type: String? {
    get {
      return resultMap["type"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "type")
    }
  }

  public var asset: String {
    get {
      return resultMap["asset"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "asset")
    }
  }

  public var jadeOrders: [String?] {
    get {
      return resultMap["jadeOrders"]! as! [String?]
    }
    set {
      resultMap.updateValue(newValue, forKey: "jadeOrders")
    }
  }

  public var latest: Bool {
    get {
      return resultMap["latest"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "latest")
    }
  }

  public var createAt: String? {
    get {
      return resultMap["createAt"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "createAt")
    }
  }

  public var projectInfo: ProjectInfo? {
    get {
      return (resultMap["projectInfo"] as? ResultMap).flatMap { ProjectInfo(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "projectInfo")
    }
  }

  public struct ProjectInfo: GraphQLSelectionSet {
    public static let possibleTypes = ["ProjectInfo"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("projectName", type: .scalar(String.self)),
      GraphQLField("logoUrl", type: .scalar(String.self)),
      GraphQLField("contractAddress", type: .scalar(String.self)),
      GraphQLField("contractExplorerUrl", type: .scalar(String.self))
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(projectName: String? = nil, logoUrl: String? = nil, contractAddress: String? = nil, contractExplorerUrl: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "ProjectInfo", "projectName": projectName, "logoUrl": logoUrl, "contractAddress": contractAddress, "contractExplorerUrl": contractExplorerUrl])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var projectName: String? {
      get {
        return resultMap["projectName"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "projectName")
      }
    }

    public var logoUrl: String? {
      get {
        return resultMap["logoUrl"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "logoUrl")
      }
    }

    public var contractAddress: String? {
      get {
        return resultMap["contractAddress"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "contractAddress")
      }
    }

    public var contractExplorerUrl: String? {
      get {
        return resultMap["contractExplorerUrl"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "contractExplorerUrl")
      }
    }
  }
}
