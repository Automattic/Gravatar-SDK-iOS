Pod::Spec.new do |s|
    s.name             = 'GravatarUI'
    s.version          = '0.1.1'
    s.summary          = 'A convient library of Gravatar UI components'
  
    s.homepage         = 'https://gravatar.com'
    s.license          = { :type => 'Mozilla Public License v2', :file => 'LICENSE.md' }
    s.authors           = 'Automattic, Inc.'
    s.source           = {
        :git => 'https://github.com/Automattic/Gravatar-SDK-iOS.git',
        :tag => s.version.to_s
    }
    s.documentation_url = 'https://automattic.github.io/Gravatar-SDK-iOS/'
      
    s.swift_version     = '5.9'
    
    ios_deployment_target = '15.0'
    s.ios.deployment_target = ios_deployment_target

    s.source_files = 'Sources/GravatarUI/**/*.swift'
    s.dependency 'Gravatar', s.version.to_s
    s.ios.framework = 'UIKit'
    
    s.test_spec 'GravatarUITests' do |swift_unit_tests|
      swift_unit_tests.platforms = {
          :ios => ios_deployment_target,
      }
      swift_unit_tests.source_files = [
          'Tests/GravatarUITests/**/*.swift'
      ]
      swift_unit_tests.resource_bundles = {
          GravatarUITestsResources: [
              'Tests/GravatarUITests/Resources/**/*'
          ]
      }
      swift_unit_tests.requires_app_host = false
    end
  end
  
  