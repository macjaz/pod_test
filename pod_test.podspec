#
# Be sure to run `pod lib lint pod_test.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'pod_test'
  s.version          = '0.0.3'
  s.summary          = 'it my pod_test'

  s.description      = <<-DESC
it is my pod_test from macjaz to all persons
                       DESC

  s.homepage         = 'https://github.com/macjaz/pod_test'
  s.license          = 'MIT'
  s.author           = { 'macjaz' => 'macjaz@163.com' }
  s.source           = { :git => 'https://github.com/macjaz/pod_test.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.source_files = 'pod_test/Classes/**/*'
  
  # s.resource_bundles = {
  #   'pod_test' => ['pod_test/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
