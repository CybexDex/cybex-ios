platform :ios, '9.0'

def network
    pod 'Starscream'
    pod 'JSONRPCKit'
    pod 'Moya'
    pod 'Kingfisher'
    pod 'RealReachability'
end

def data
    pod 'ObjectMapper'
    pod 'SwiftyJSON'
    pod 'BigInt'
    pod 'GRDB.swift'
    pod 'CryptoSwift'
    pod 'RxGRDB'
    pod 'SwiftyUserDefaults'
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
   pod 'Localize-Swift'
   pod 'SwiftTheme'
   pod 'UIFontComplete'
   pod 'RxCocoa'
   pod 'AwaitKit'
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
    pod 'EZSwiftExtensions', :git => 'https://github.com/Steven-Cheung/EZSwiftExtensions', :branch => 'swift4'
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
    pod 'TextFieldEffects'
    pod 'MJRefresh'
    pod 'IHKeyboardAvoiding'
    pod 'Typist'
    pod 'RxGesture'
    pod 'SwiftRichString', :git => 'https://github.com/malcommac/SwiftRichString', :tag => '2.0.1'
    pod 'ZLaunchAd'
    pod 'SDCAlertView'
    pod 'Presentr'
    pod 'Macaw'
end

def other
    pod 'Siren'
    pod 'LifetimeTracker'
    pod 'MLeaksFinder'
end

def fabric
    pod 'Fabric'
    pod 'Crashlytics'
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

end


