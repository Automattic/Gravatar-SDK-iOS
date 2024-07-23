require_relative 'version'

Pod::Spec.new do |s|
  s.name             = 'Gravatar'
  s.version          = Gravatar::VERSION
  s.summary          = 'A convient library for accessing the Gravatar API'

  s.homepage         = 'https://gravatar.com'
  s.license          = { :type => 'Mozilla Public License v2', :file => 'LICENSE.md' }
  s.authors           = 'Automattic, Inc.'
  s.source           = {
      :git => 'https://github.com/Automattic/Gravatar-SDK-iOS.git',
      :tag => s.version.to_s
  }
  s.documentation_url = 'https://automattic.github.io/Gravatar-SDK-iOS/'
    
  s.swift_versions    = Gravatar::SWIFT_VERSIONS

  ios_deployment_target = '15.0'

  s.ios.deployment_target = ios_deployment_target

  s.source_files = 'Sources/Gravatar/**/*.swift'

  # Using the `package` access level for types requires us to pass `-package-name`
  # as a swift flag, with the same name for each module/pod
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -package-name -Xfrontend gravatar_sdk_ios'
  }
end
