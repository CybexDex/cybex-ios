platform :ios, '9.0'

plugin 'cocoapods-wholemodule'

def network
    pod 'Starscream'
    pod 'JSONRPCKit'
    pod 'Moya'
    pod 'Kingfisher'
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
    pod 'IHKeyboardAvoiding'
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
    pod 'Atributika'
    pod 'ZLaunchAd'
    pod 'SDCAlertView'
    pod 'Presentr'
    pod 'Macaw'
    pod 'IGIdenticon'
end

def other
    pod 'Siren'
end

def fabric
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'cybexMobile' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Reveal-SDK', :configurations => ['Debug']
  pod 'LifetimeTracker'
  pod 'RealReachability'
  pod 'MLeaksFinder'
  
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
  
  # Pods for cybexMobile
  target 'cybexMobileTests' do
    inherit! :search_paths
    # Pods for testing
#    pod 'Quick'
#    pod 'Nimble'
#    pod 'OHHTTPStubs'
  end

end


