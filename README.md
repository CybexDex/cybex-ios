# cybex-ios

[![Build Status](https://travis-ci.org/CybexDex/cybex-ios.svg?branch=develop)](https://travis-ci.org/CybexDex/cybex-ios)

配置

APP server配置在 https://github.com/CybexDex/cybex-ios/blob/master/cybexMobile/Services/Network/HTTP/Configuation/AppService.swift
```
struct AppService {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://app.cybex.io")!  // 生产config server
        static let devURL = URL(string: "http://47.91.242.71:3039")!
        static let uatURL = URL(string: "http://47.100.98.113:3039")! // uat config server, 可以配置成域名http://uatapp.51nebula.com 
    }
```

水龙头配置在 https://github.com/CybexDex/cybex-ios/blob/master/cybexMobile/Services/Network/HTTP/Register/RegisterService.swift
```
struct RegisterService {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://faucet.cybex.io")! // 生产水龙头
        static let devURL = URL(string: "https://faucet.51nebula.com")!
        static let uatURL = URL(string: "https://uatfaucet.51nebula.com")! // uat水龙头
    }
```

History server配置在 https://github.com/CybexDex/cybex-ios/blob/master/cybexMobile/Services/Network/HTTP/AccountHistory/AccountHistoryService.swift
```
struct AccountHistoryService {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://live.cybex.io")! // 生产
        static let devURL = URL(string: "http://39.105.55.115:8081")!
        static let uatURL = URL(string: "http://47.100.98.113:8081")! // uat域名 http://uatliveapi.51nebula.com
    }
```
节点等配置信息配置在config server, 详情参考 https://github.com/CybexDex/config-server
