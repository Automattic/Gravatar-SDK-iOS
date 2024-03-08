Pod::Spec.new do |s|
  s.name             = 'Gravatar'
  s.version          = '0.1.0'
  s.summary          = 'Gravatar SDK'

  s.description      = <<-DESC
Gravatar SDK provides a convient wrapper for accessing the Gravatar API
                       DESC

  s.homepage         = 'https://gravatar.com'
  s.license          = { :type => 'Mozilla Public License v2', :file => 'LICENSE.md' }
  s.authors           = 'Automattic, Inc.'
  s.source           = {
      :git => 'https://github.com/Automattic/Gravatar-SDK-iOS.git',
      :tag => 'CocoaPods-' + s.version.to_s
  }

  s.swift_version     = '5.9'

  ios_deployment_target = '15.0'

  s.ios.deployment_target = ios_deployment_target

  s.source_files = 'Sources/**/*.swift'

  s.test_spec 'Tests' do |swift_unit_tests|
    swift_unit_tests.platforms = {
        :ios => ios_deployment_target,
    }
    swift_unit_tests.source_files = [
        'Tests/**/*.swift'
    ]
    swift_unit_tests.resource_bundles = {
        GravatarTestsResources: [
            'Tests/GravatarTests/Resources/**/*'
        ]
    }
    swift_unit_tests.requires_app_host = false
  end
end

