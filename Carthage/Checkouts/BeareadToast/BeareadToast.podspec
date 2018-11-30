#
#  Be sure to run `pod spec lint BeareadToast.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "BeareadToast"
  s.version      = "0.0.3"
  s.summary      = "BeareadToast is bearead custom toast."
  s.description  = <<-DESC
                    Bearead Custom Toast, with Different Style.
                  DESC

  s.homepage     = "https://github.com/BeareadIO/BeareadToast"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "UnicornBoss" => "archyvan9092@gmail.com" }
  s.platform     = :ios, "9.0"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  s.source       = { :git => "https://github.com/BeareadIO/BeareadToast.git", :tag => "#{s.version}" }
  s.source_files  = "BeareadToast/BeareadToast/*.swift"
  s.resource_bundle = {
  		'BeareadToast' => ['BeareadToast/BeareadToast.bundle/*.png']
  }

end
