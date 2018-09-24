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
    pod 'Cache'
    pod 'Locksmith'
    pod 'Then'
    pod 'FCUUID'
    pod 'IQKeyboardManagerSwift', :git => 'https://github.com/hackiftekhar/IQKeyboardManager', :tag => 'v6.1.1'
    pod 'DifferenceKit'
    pod 'Dollar'
    pod 'Validator'
    pod 'Fakery', :git => 'https://github.com/vadymmarkov/Fakery', :branch => 'master'
end

def resource
    pod 'R.swift'
end

def architecture
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
   pod 'URLNavigator'
end

def permission
    pod 'Proposer'
    pod 'BiometricAuthentication'
end

def animation

end

def extension
    pod 'KeychainAccess'
    pod 'SwifterSwift'
    pod 'Repeat'
end

def ui
    pod 'TinyConstraints'
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
#    pod 'ZLaunchAd'
    pod 'Presentr'
    pod 'Macaw'
#    pod 'SwiftEntryKit'
    pod 'Keyboard+LayoutGuide'
#    pod 'XLPagerTabStrip'
    pod 'EFQRCode'
    pod 'GrowingTextView'
    pod 'XLActionController'
    pod 'ESPullToRefresh'
    pod 'FSPagerView'
    pod 'ActiveLabel'
#    pod 'SkeletonView'
end

def other
    pod 'Siren'
#    pod 'MLeaksFinder'
    pod 'Device'
#    pod 'SwiftNotificationCenter'
    pod 'AsyncSwift'
    pod 'MonkeyKing' #share
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
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
