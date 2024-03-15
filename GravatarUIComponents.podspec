Pod::Spec.new do |s|
    s.name             = 'GravatarUIComponents'
    s.version          = '0.1.1'
    s.summary          = 'A convient library for accessing the Gravatar API'
  
    s.homepage         = 'https://gravatar.com'
    s.license          = { :type => 'Mozilla Public License v2', :file => 'LICENSE.md' }
    s.authors           = 'Automattic, Inc.'
    s.source           = {
        :git => 'https://github.com/Automattic/Gravatar-SDK-iOS.git',
        :tag => s.version.to_s
    }
    s.documentation_url = 'https://automattic.github.io/Gravatar-SDK-iOS/'
      
    s.swift_version     = '5.9'
    
    s.platform = :ios
    
    ios_deployment_target = '15.0'
    
    s.ios.deployment_target = ios_deployment_target
    s.source_files = 'Sources/GravatarUIComponents/**/*.swift'
    
    s.test_spec 'GravatarUIComponents' do |swift_unit_tests|
      swift_unit_tests.platforms = {
          :ios => ios_deployment_target,
      }
      swift_unit_tests.source_files = [
          'Tests/GravatarUIComponentsTests/**/*.swift'
      ]
      swift_unit_tests.resource_bundles = {
          GravatarTestsResources: [
              'Tests/GravatarUIComponentsTests/Resources/**/*'
          ]
      }
      swift_unit_tests.requires_app_host = false
    end
  end
  
  