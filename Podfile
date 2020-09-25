# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
#supports_swift_versions '>= 5.0'
inhibit_all_warnings!

#install! 'cocoapods',
#  :generate_multiple_pod_projects => true,
#  :incremental_installation => true


target 'cybexMobile' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for cybexMobile
#    pod 'UMCCommon'
#    pod 'UMCAnalytics'
    pod 'coswift'
    pod 'EFQRCode', '~> 5.0.0'

    pod 'DoraemonKit/Core', :configurations => ['Debug']
    pod 'DoraemonKit/WithLogger', :configurations => ['Debug']
    pod 'LookinServer', :configurations => ['Debug']

    pod 'Kingfisher', '~> 5.0'
    pod 'RxCocoa', '~> 5'
    pod 'Moya', '~> 13.0'
    pod "RxGesture"
    pod 'UMCCommon'
    pod 'UMCAnalytics'
    pod 'WKWebViewJavascriptBridge'
    pod 'web3swift'
    pod 'Presentr'
    pod "ESTabBarController-swift"
    pod 'TangramKit'
    pod 'NotificationBannerSwift', '~> 3.0.0'
    pod 'XLPagerTabStrip', '~> 9.0'
    pod 'NVActivityIndicatorView'
    pod 'GrowingTextView', '0.7.2'
    pod 'Reusable'
    pod 'FSPagerView'
    pod "Macaw", '0.9.7'
    pod "Device", '~> 3.2.1'
    pod 'UIFontComplete'
    pod 'SDCAlertView'
    pod 'BiometricAuthentication'
    pod "ESPullToRefresh"
    pod 'AnyCodable-FlightSchool', '~> 0.3.0'
    pod 'SwiftTheme'
    pod 'Localize-Swift', '~> 2.0'
    pod 'HandyJSON', '~> 5.0.2'
    pod "TinyConstraints"

  target 'cybexMobileTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

#post_install do |installer|
#  installer.pod_target_subprojects.each do |project|
#    project.build_configurations.each do |config|
#      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
#      config.build_settings['SWIFT_VERSION'] = '5.0'
#    end
#    project.targets.each do |target|
#      target.build_configurations.each do |config|
#        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
#        config.build_settings['SWIFT_VERSION'] = '5.0'
#      end
#    end
#  end
#end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      if config.name == 'Debug'
#        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
#        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
#      end
#    end
#  end
#end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end
