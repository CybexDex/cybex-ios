platform :ios, '10.0'

def network
    pod 'JSONRPCKit', :git => 'https://github.com/phpmaple/JSONRPCKit', :branch => 'master'
    pod 'ReachabilitySwift'
    pod 'Apollo'
end

def data
    pod 'ObjectMapper'
    pod 'SwiftyJSON'
    pod 'CryptoSwift'
    pod 'SwiftyUserDefaults',:git => 'https://github.com/radex/SwiftyUserDefaults', :tag => '4.0.0-alpha.1'
    pod 'Zephyr'
#    pod 'Cache'
    pod 'Locksmith'
    pod 'Then'
    pod 'FCUUID'
    pod 'IQKeyboardManagerSwift', :git => 'https://github.com/hackiftekhar/IQKeyboardManager', :tag => 'v6.1.1'
    pod 'DifferenceKit', :git => 'https://github.com/ra1028/DifferenceKit', :branch => 'master'
    pod 'Dollar'
#    pod 'Validator'
    pod 'Fakery', :git => 'https://github.com/vadymmarkov/Fakery', :branch => 'master'
end

def resource
    pod 'R.swift', :git => 'https://github.com/mac-cain13/R.swift', :branch => 'master'
end

def architecture
#   pod 'ObservableArray-RxSwift'
#   pod 'RxSwiftExt'
#   pod 'RxDataSources'
#   pod 'RxKeyboard'
#   pod 'RxValidator'
#   pod 'Action'

   pod 'Lightning'

   pod 'Localize-Swift'
   pod 'SwiftTheme', :git => 'https://github.com/jiecao-fm/SwiftTheme', :branch => 'master'
   pod 'UIFontComplete'
#   pod 'RxCocoa'
   pod 'AwaitKit'
   
   pod 'AsyncOperation'
   pod 'URLNavigator'
end

def permission
    pod 'Proposer', :git => 'https://github.com/nixzhu/Proposer', :branch => 'master'
    pod 'BiometricAuthentication'
end

def animation

end

def extension
    pod 'KeychainAccess'
    pod 'SwifterSwift', :git => 'https://github.com/SwifterSwift/SwifterSwift', :branch => 'master'
    pod 'Repeat'
end

def ui
    pod 'TinyConstraints', :git => 'https://github.com/roberthein/TinyConstraints', :branch => 'release/Swift-4.2'
    pod 'KMNavigationBarTransition'
#    pod 'NVActivityIndicatorView'
    pod 'BeareadToast', :git => 'https://github.com/phpmaple/BeareadToast', :branch => 'master'
    pod 'DNSPageView'
    pod 'MJRefresh'
#    pod 'TextFieldEffects'
#    pod 'IHKeyboardAvoiding'
#    pod 'Typist'
    pod 'RxGesture', :git => 'https://github.com/RxSwiftCommunity/RxGesture', :tag => '2.0.1'
    pod 'SwiftRichString', :git => 'https://github.com/mezhevikin/SwiftRichString', :branch => 'swift4.2', :inhibit_warnings => true
#    pod 'ZLaunchAd'
    pod 'Presentr'
    pod 'Macaw', :git => 'https://github.com/exyte/Macaw', :branch => 'master'
#    pod 'SwiftEntryKit'
#    pod 'Keyboard+LayoutGuide'
#    pod 'XLPagerTabStrip'
    pod 'EFQRCode'
    pod 'GrowingTextView', :git => 'https://github.com/phpmaple/GrowingTextView', :branch => 'swift4.2'
    pod 'XLActionController', :git => 'https://github.com/xmartlabs/XLActionController', :branch => 'Swift4.2'
    pod 'ESPullToRefresh', :git => 'https://github.com/phpmaple/pull-to-refresh', :branch => 'swift-4.2'
    pod 'FSPagerView', :git => 'https://github.com/WenchaoD/FSPagerView', :tag => '0.8.1'
    pod 'ActiveLabel', :git => 'https://github.com/optonaut/ActiveLabel.swift', :branch => 'master'
#    pod 'SkeletonView'
end

def other
    pod 'Siren'
#    pod 'MLeaksFinder'
    pod 'Device'
#    pod 'SwiftNotificationCenter'
    pod 'AsyncSwift'
    pod 'MonkeyKing', :git => 'https://github.com/nixzhu/MonkeyKing', :branch => 'master' #share
end

def scripts
#    pod 'SwiftGen'
#    pod 'Sourcery'
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
#  use_frameworks!
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
  scripts
  
  target 'cybexMobileTests' do
      inherit! :search_paths
      # Pods for testing
      pod 'Nimble'
      pod 'Quick'
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'cybexMobile'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
                if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
                end
            end
        end
    end
end
