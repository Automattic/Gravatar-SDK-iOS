# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name             = 'GravatarOpenAPIClient'
  s.summary          = 'A Gravatar OpenAPI Client'
  s.version          = '2.1.1'

  # These are defined by openapi-generator
  s.ios.deployment_target = Gravatar::IOS_DEPLOYMENT_TARGET

  s.homepage = 'https://gravatar.com'
  s.license = { type: 'Mozilla Public License v2', file: 'LICENSE.md'}
  s.authors = 'Automattic, Inc.'
  s.source = { :git => 'https://github.com/Automattic/Gravatar-SDK-iOS.git', :tag => s.version.to_s }

  s.documentation_url = 'https://automattic.github.io/Gravatar-SDK-iOS/gravatar'

  s.source_files = 'Sources/GravatarOpenAPIClient/**/*.swift'
end
