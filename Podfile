# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

flutter_application_path = './cybex_flutter/'
eval(File.read(File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')), binding)

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
    pod 'Moya'
    pod 'web3swift.pod'

  target 'cybexMobileTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
#
#post_install do |installer|
#  # Downgrade Swift language version to 4.0 for Pods that don't support Swift 5
#  installer.pods_project.targets.each do |target|
#    if ['Web3'].include? target.name
#      target.build_configurations.each do |config|
#        config.build_settings['SWIFT_VERSION'] = '4.0'
#      end
#    end
#  end
#end
