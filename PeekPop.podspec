#
# Be sure to run `pod lib lint PeekPop.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PeekPop"
  s.version          = "1.0.0"
  s.summary          = "Backwards-compatible peek and pop."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                      Swift framework that enables peek and pop in devices without 3D touch.
                     DESC

  s.homepage         = "https://github.com/marmelroy/PeekPop"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Roy Marmelstein" => "marmelroy@gmail.com" }
  s.source           = { :git => "https://github.com/marmelroy/PeekPop.git", :tag => s.version.to_s, :submodules => true}
  s.social_media_url   = "http://twitter.com/marmelroy"

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.source_files = "PeekPop"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Accelerate'
  # s.dependency 'AFNetworking', '~> 2.3'

end
