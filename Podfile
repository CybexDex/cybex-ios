# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
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
    pod 'secp256k1_swift'

  target 'cybexMobileTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

