# frozen_string_literal: true

default_platform(:ios)

UI.user_error!('Please run fastlane via `bundle exec`') unless FastlaneCore::Helper.bundler?

GLOTPRESS_PROJECT_BASE_URL = 'https://translate.wordpress.com/projects/gravatar/gravatar-ios-sdk/'
RESOURCES_TO_LOCALIZE = {
  File.join('Sources', 'GravatarUI', 'Resources') => "#{GLOTPRESS_PROJECT_BASE_URL}/gravatarui/"
}.freeze

def localizable_source(source_paths:, localization_root:, gp_project:)
  {
    source_paths: source_paths,
    localization_root: localization_root,
    gp_project: gp_project
  }
end

SOURCES_TO_LOCALIZE = [
  localizable_source(
    source_paths: [File.join('Sources', 'GravatarUI')],
    localization_root: File.join('Sources', 'GravatarUI', 'Resources'),
    gp_project: "#{GLOTPRESS_PROJECT_BASE_URL}/gravatarui/"
  ),
  localizable_source(
    source_paths: [
      File.join('Demo', 'Demo', 'Gravatar-UIKit-Demo'),
      File.join('Demo', 'Demo', 'Gravatar-SwiftUI-Demo')
    ],
    localization_root: File.join('Demo', 'Demo', 'Localizations'),
    gp_project: nil  # We don't perform translations for the Demo project yet
  )
].freeze

# List of locales used for the app strings (GlotPress code => `*.lproj` folder name`)
#
# TODO: Replace with `LocaleHelper` once provided by release toolkit (https://github.com/wordpress-mobile/release-toolkit/pull/296)
GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES = {
  'ar' => 'ar',         # Arabic
  'de' => 'de',         # German
  'es' => 'es',         # Spanish
  'fr' => 'fr',         # French
  'he' => 'he',         # Hebrew
  'id' => 'id',         # Indonesian
  'it' => 'it',         # Italian
  'ja' => 'ja',         # Japanese
  'ko' => 'ko',         # Korean
  'nl' => 'nl',         # Dutch
  'pt-br' => 'pt-BR',   # Portuguese (Brazil)
  'ru' => 'ru',         # Russian
  'sv' => 'sv',         # Swedish
  'tr' => 'tr',         # Turkish
  'zh-cn' => 'zh-Hans', # Chinese (China)
  'zh-tw' => 'zh-Hant'  # Chinese (Taiwan)
}.freeze

#################################################
# Lanes
#################################################

# Lanes related to Localization and GlotPress
#
platform :ios do
  # Download the latest localizations from GlotPress and update the SDK accordingly.
  #
  # @example Running the lane
  #          bundle exec fastlane download_localized_strings skip_commit:true
  #
  desc 'Downloads localized strings (`.strings`) from GlotPress and commits them'
  lane :download_localized_strings do |skip_commit: false|
    paths_to_commit = []

    SOURCES_TO_LOCALIZE.each do |source|
      next if source[:gp_project].nil?

      ios_download_strings_files_from_glotpress(
        project_url: source[:gp_project],
        locales: GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES,
        download_dir: source[:localization_root]
      )

      next if skip_commit

      git_add(path: source[:localization_root])
      paths_to_commit << source[:localization_root]
    end

    next if skip_commit

    git_commit(
      path: paths_to_commit,
      message: 'Update localizations',
      allow_nothing_to_commit: true
    )
  end

  # Generates the `.strings` files for the base language by parsing source code (using `genstring`).
  #
  lane :generate_strings do |skip_commit: false|
    paths_to_commit = []

    SOURCES_TO_LOCALIZE.each do |source|
      Dir.mktmpdir do |tempdir|
        ios_generate_strings_file_from_code(
          paths: source[:source_paths],
          output_dir: tempdir
        )

        utf16_strings = File.join(tempdir, 'Localizable.strings')
        utf8_strings = File.join('..', source[:localization_root], 'en.lproj', 'Localizable.strings')

        utf16_to_utf8(
          source: utf16_strings,
          destination: utf8_strings
        )
      end

      next if skip_commit

      git_add(path: source[:localization_root])
      paths_to_commit << source[:localization_root]
    end

    next if skip_commit

    git_commit(
      path: paths_to_commit,
      message: 'Update strings in base locale',
      allow_nothing_to_commit: true
    )
  end

  private_lane :utf16_to_utf8 do |options|
    next unless options[:source]
    next unless options[:destination]

    source = options[:source]
    destination = options[:destination]

    next unless File.exist?(source)

    File.open(source, 'rb:UTF-16') do |in_file|
      utf16_content = in_file.read
      utf8_content = utf16_content.encode('UTF-8')

      File.open(destination, 'w:UTF-8') do |out_file|
        out_file.write(utf8_content)
      end
    end
  end
end
