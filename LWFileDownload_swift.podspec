#
# Be sure to run `pod lib lint LWFileDownload_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWFileDownload_swift'
  s.version          = '1.0.0'
  s.summary          = 'LWFileDownload的Swift版本，支持单文件与多文件下载管理。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWFileDownload_swift，Swift版本的文件下载管理器，支持单文件与多文件下载，提供下载进度、暂停、恢复、取消等功能。
                       DESC

  s.homepage         = 'https://github.com/luowei/LWFileDownload.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWFileDownload.git'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'LWFileDownload_swift/Classes/**/*'

  # s.resource_bundles = {
  #   'LWFileDownload_swift' => ['LWFileDownload_swift/Assets/*.png']
  # }

  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

end
