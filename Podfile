platform :ios, '9.0'

def network
#    pod 'Starscream'
    pod 'SocketRocket', :git => 'https://github.com/facebook/SocketRocket', :branch => 'master'
    pod 'JSONRPCKit'
    pod 'Moya'
    pod 'Kingfisher'
    pod 'RealReachability'
    pod 'Apollo'
    pod 'AlamofireNetworkActivityLogger'
end

def data
    pod 'ObjectMapper'
    pod 'HandyJSON'
    pod 'SwiftyJSON'
    pod 'BigInt'
    pod 'GRDB.swift'
    pod 'CryptoSwift'
    pod 'RxGRDB'
    pod 'SwiftyUserDefaults',:git => 'https://github.com/radex/SwiftyUserDefaults', :tag => '4.0.0-alpha.1'
    pod 'Zephyr'
    pod 'Cache'
    pod 'Locksmith'
    pod 'Then'
    pod 'FCUUID'
    pod 'IQKeyboardManagerSwift'
    pod 'Guitar'
end

def resource
    pod 'R.swift'
end

def architecture
   pod 'ReSwift'
   pod 'RxSwift'
   pod 'ObservableArray-RxSwift'
   pod 'RxSwiftExt'
   pod 'RxDataSources'
   pod 'RxKeyboard'
   pod 'RxValidator'
   pod 'Action'

   pod 'Lightning'

   pod 'Localize-Swift'
   pod 'SwiftTheme'
   pod 'UIFontComplete'
   pod 'RxCocoa'
   pod 'AwaitKit'
   
   pod 'AsyncOperation'
end

def permission
    pod 'Proposer'
    pod 'BiometricAuthentication'
end

def animation
    pod 'EasyAnimation'
#    pod 'Hero'
    pod 'ChainableAnimations'
    pod 'TableFlip'
end

def extension
    pod 'KeychainAccess'
    pod 'SwifterSwift'
    pod 'Repeat'
end

def ui
    pod 'TinyConstraints'
    pod 'ESTabBarController-swift'
    pod 'KMNavigationBarTransition'
    pod 'NVActivityIndicatorView'
    pod 'BeareadToast', :git => 'https://github.com/phpmaple/BeareadToast'
    pod 'DNSPageView'
    pod 'MJRefresh'
    pod 'TextFieldEffects'
    pod 'IHKeyboardAvoiding'
    pod 'Typist'
    pod 'RxGesture'
    pod 'SwiftRichString', :git => 'https://github.com/malcommac/SwiftRichString', :tag => '2.0.1'
    pod 'ZLaunchAd'
    pod 'SDCAlertView'
    pod 'Presentr'
    pod 'Macaw'
    pod 'SwiftEntryKit'
    pod 'Keyboard+LayoutGuide'
    pod 'XLPagerTabStrip'
    pod 'EFQRCode'
    pod 'GrowingTextView'
    pod 'XLActionController'
    pod 'ESPullToRefresh'
end

def other
    pod 'Siren'
    pod 'LifetimeTracker'
    pod 'MLeaksFinder'
    pod 'Device'
end

def fabric
    pod 'Fabric'
    pod 'Crashlytics'
end

def debug
    pod 'SwiftyBeaver'
#   pod 'AppSpectorSDK'
#   pod 'WoodPeckeriOS', '>= 1.0.3', :configurations => ['Debug']
end

def um
    pod 'UMCCommon'
    pod 'UMCSecurityPlugins'
    pod 'UMCAnalytics'
    pod 'UMCCommonLog'
end

target 'cybexMobile' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  pod 'Reveal-SDK', :configurations => ['Debug']
  
  
  
  
  fabric
  network
  animation
  data
  resource
  architecture
  permission
  extension
  ui
  other
  debug
  um
end
