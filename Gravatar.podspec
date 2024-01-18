Pod::Spec.new do |s|
  s.name             = 'Gravatar'
  s.version          = '0.1.0'
  s.summary          = 'Helpful for Gravatar'
  s.swift_version    = '5.9'

  s.description      = <<-DESC
  Does gravatar things in a gravatar way
                       DESC

  s.homepage         = 'https://github.com/gravatar/Gravatar-SDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pinar Olguc' => 'pinar.olguc@automattic.com' }
  s.source           = { :git => 'https://github.com/Pinar Olguc/Gravatar.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.tvos.deployment_target = '15.0'

  s.source_files = 'Sources/Gravatar/**/*'
  
  # s.resource_bundles = {
  #   'Gravatar' => ['Gravatar/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
