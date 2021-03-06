#
# Be sure to run `pod lib lint URIDrumKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'URIDrumKit'
  s.version          = '0.2.3'
  s.summary          = 'Library to easily handle Universal Links in iOS app'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/pencildrummer/URIDrumKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pencildrummer' => 'info@pencildrummer.com' }
  s.source           = { :git => 'https://github.com/pencildrummer/URIDrumKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'URIDrumKit/Classes/**/*'

end
