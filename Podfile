# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
#supports_swift_versions '>= 5.0'
inhibit_all_warnings!

install! 'cocoapods',
  :generate_multiple_pod_projects => true,
  :incremental_installation => true

target 'ChatRoom' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatRoom

end

target 'cybexMobile' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for cybexMobile

    pod 'coswift'
    pod 'secp256k1_swift'
    pod 'EFQRCode', '~> 5.0.0'

  target 'cybexMobileTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pod_target_subprojects.each do |project|
    project.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
  end
end
