# frozen_string_literal: true

default_platform(:ios)

UI.user_error!('Please run fastlane via `bundle exec`') unless FastlaneCore::Helper.bundler?

GLOTPRESS_PROJECT_BASE_URL = 'https://translate.wordpress.com/projects/gravatar/gravatar-ios-sdk/'
RESOURCES_TO_LOCALIZE = {
  File.join('Sources', 'GravatarUI', 'Resources') => "#{GLOTPRESS_PROJECT_BASE_URL}/gravatarui/",
}.freeze

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
    RESOURCES_TO_LOCALIZE.each do |res_dir, gp_url|
      ios_download_strings_files_from_glotpress(
        project_url: gp_url,
        locales: GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES,
        download_dir: res_dir
      )
    end

    next if skip_commit

    strings_paths = RESOURCES_TO_LOCALIZE .keys.map(&:to_s)
    git_add(path: strings_paths)
    git_commit(
      path: strings_paths,
      message: 'Update localizations',
      allow_nothing_to_commit: true
    )
  end

    # Generates the `.strings` file, by parsing source code (using `genstrings` under the hood).
    #
    lane :generate_strings_file do |options|
      generate_strings_file_demo(options)
      generate_strings_file_sdk(options)
    end
  
    lane :generate_strings_file_demo do |options|
      Dir.mktmpdir do |tempdir|
        demo_en_lproj = File.join('Demo', 'Demo', 'Localizations', 'en.lproj')
        ios_generate_strings_file_from_code(
          paths: [
            File.join('Demo', 'Demo', 'Gravatar-UIKit-Demo'),
            File.join('Demo', 'Demo', 'Gravatar-SwiftUI-Demo')
          ],
          output_dir: tempdir        )
  
        utf16_strings = File.join(tempdir, 'Localizable.strings')
        utf8_strings = File.join("..", demo_en_lproj, 'Localizable.strings')

        utf16_to_utf8(
          source: utf16_strings,
          destination: utf8_strings
        )
      end
    end
  
    lane :generate_strings_file_sdk do |options|
      Dir.mktmpdir do |tempdir|
        demo_en_lproj = File.join('Sources', 'GravatarUI', 'Resources', 'en.lproj')
        ios_generate_strings_file_from_code(
          paths: [
            File.join('Sources', 'GravatarUI')
          ],
          output_dir: tempdir
        )
  
        utf16_strings = File.join(tempdir, 'Localizable.strings')
        utf8_strings = File.join("..", demo_en_lproj, 'Localizable.strings')

        utf16_to_utf8(
          source: utf16_strings,
          destination: utf8_strings
        )
      end
    end


  
    private_lane :utf16_to_utf8 do |options|
      next unless options[:source]
      next unless options[:destination]      
  
      source = options[:source]
      destination = options[:destination]
  
      next unless File.exist?(source)
      File.open(source, "rb:UTF-16") do |in_file|
        utf16_content = in_file.read
        utf8_content = utf16_content.encode("UTF-8")

        File.open(destination, "w:UTF-8") do |out_file|
          out_file.write(utf8_content)
        end
      end
    end
  end
  