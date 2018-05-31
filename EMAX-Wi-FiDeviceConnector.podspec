#
#  Be sure to run `pod spec lint EMAX-Wi-FiDeviceConnector.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "EMAX-Wi-FiDeviceConnector"
  s.version      = "0.1.0"
  s.summary      = "Framework container ConnectorManager class and customizable UI."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  #s.description  = <<-DESC
  #                 DESC

  s.homepage     = "https://github.com/libercata/EMAX-Wi-FiDeviceConnector"

    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    
  s.license      = "MIT"

  s.author       = { "Waynnn" => "imhwn@vip.qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/libercata/EMAX-Wi-FiDeviceConnector.git", :tag => "#{s.version}" }

  s.source_files = 'EMAXConnector/**/*.{h,m}'
  s.resource     = 'EMAXConnector/Connector.bundle'


  s.requires_arc = true

end
