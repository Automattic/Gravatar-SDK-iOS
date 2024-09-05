# frozen_string_literal: true

require 'fileutils'
require_relative '../localizable_source'

default_platform(:ios)

GLOTPRESS_PROJECT_BASE_URL = 'https://translate.wordpress.com/projects/gravatar/gravatar-ios-sdk/'

SOURCES_TO_LOCALIZE = [
  LocalizableSource.new(
    source_paths: [File.join('Sources', 'GravatarUI')],
    localizations_root: File.join('Sources', 'GravatarUI', 'Resources'),
    gp_project_url: "#{GLOTPRESS_PROJECT_BASE_URL}/gravatarui/"
  ),
  LocalizableSource.new(
    source_paths: [
      File.join('Demo', 'Demo', 'Gravatar-UIKit-Demo'),
      File.join('Demo', 'Demo', 'Gravatar-SwiftUI-Demo')
    ],
    localizations_root: File.join('Demo', 'Demo', 'Localizations'),
    gp_project_url: nil # We don't perform translations for the Demo project yet
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
      next if source.gp_project_url.nil?

      ios_download_strings_files_from_glotpress(
        project_url: source.gp_project_url,
        locales: GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES,
        download_dir: source.localizations_root
      )

      next if skip_commit

      paths_to_commit << source.localizations_root
    end

    next if skip_commit

    git_add(path: paths_to_commit)
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
      ios_generate_strings_file_from_code(
        paths: source.source_paths,
        output_dir: source.base_localization_root
      )

      Dir.chdir('..') do
        convert_generated_strings(source: source)
      end

      next if skip_commit

      paths_to_commit << source.localizations_root
    end

    next if skip_commit

    git_add(path: paths_to_commit)
    git_commit(
      path: paths_to_commit,
      message: 'Update strings in base locale',
      allow_nothing_to_commit: true
    )
  end

  # Converts the base localization `.strings` files of a `LocalizationSource`
  # from UTF-16 encoding to UTF-8 encoding
  #
  # @param source [LocalizableSource] An object that represents a localizable source
  # @return [void]
  #
  # @example Convert all `.strings` files from UTF-16 to UTF-8.
  #   convert_generated_strings(
  #     source: LocalizationSource.new(source_paths: ['/source/path'], localizations_root: 'Localizations'),
  #   )
  #
  def convert_generated_strings(source:)
    Dir.mktmpdir do |tempdir|
      source.base_localization_strings_paths.each do |strings_file|
        convert_file(strings_file: strings_file, tempdir: tempdir)
      end
    end
  end

  # Converts a file from UTF-16 to UTF-8 using a temp directory to ensure that the conversion is successfull
  # before overwriting the original file
  #
  # @param strings_file [String] path to the `.strings` file to convert
  # @param tempdir [String] path to a temporary directory to be used for the conversion
  # @return [void]
  #
  def convert_file(strings_file:, tempdir:)
    utf8_strings_file = convert_file_to_utf8(strings_file: strings_file, tempdir: tempdir)

    copy_converted_file(utf8_strings_file: utf8_strings_file, original_strings_file: strings_file) unless utf8_strings_file.nil?
  end

  # Converts a UTF-16 `.strings` file to UTF-8 and writes it to the specified path.
  #
  # @param strings_file [String] the path to the original UTF-16 `.strings` file
  # @param tempdir [String] temp directory for storing the encoded file
  # @return [Boolean] returns `true` if the conversion succeeds, or `false` if the file is not UTF-16
  # @raise [StandardError] if a general error occurs during file conversion
  #
  def convert_file_to_utf8(strings_file:, tempdir:)
    utf8_strings_file = File.join(tempdir, File.basename(strings_file))
    possible_utf16_content = File.read(strings_file, mode: 'rb:UTF-16')
    utf8_content = possible_utf16_content.encode('UTF-8')
    UI.message("Converting: #{strings_file}")
    File.write(utf8_strings_file, utf8_content, mode: 'w:UTF-8')
    utf8_strings_file
  rescue Encoding::InvalidByteSequenceError
    UI.message("Skipping non-UTF-16 file: #{strings_file}")
    nil
  rescue StandardError => e
    UI.error("An error occurred during conversion: #{e.message}")
    raise
  end

  # Copies the UTF-8 converted `.strings` file back to its original location.
  #
  # @param [String] utf8_strings_file the path to the converted UTF-8 `.strings` file in the temp directory
  # @param [String] original_strings_file the path to the original file that should be overwritten
  # @return [void]
  # @raise [StandardError] if an error occurs during the copy process
  #
  def copy_converted_file(utf8_strings_file:, original_strings_file:)
    FileUtils.cp(utf8_strings_file, original_strings_file)
  rescue StandardError => e
    UI.error("An error occurred during file copy: #{e.message}")
    raise
  end
end
