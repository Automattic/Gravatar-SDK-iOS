# frozen_string_literal: true

# Represents a localizable source for generating strings and downloading localizations from GlotPress.
#
# Example:
#
#   localizable = LocalizableSource.new(
#     source_paths: ['/path/to/source1', '/path/to/source2'],
#     localizations_root: '/path/to/localizations',
#     base_locale: 'en',
#     gp_project_url: 'https://example.com/project'
#   )
#
#   puts localizable.base_localization_strings
#   # Output: /path/to/localizations/en.lproj/Localizable.strings
#
#   puts localizable.base_localization_strings(table_name: 'Example')
#   # Output: /path/to/localizations/en.lproj/Example.strings
#
class LocalizableSource
  # @return [Array<String>] An array of paths to source files we want to scan for localization are stored.
  # This can include multiple directories where localized resources are kept.
  attr_accessor :source_paths

  # @return [String] The parent directory containing the `.lproj` folders.
  attr_accessor :localizations_root

  # @return [String] The two-character locale that serves as the base local for localization
  attr_accessor :base_locale

  # @return [String, nil] An optional URL to the translation management system or project repository.
  # If `nil`, base localization files can be generated, but no localizations can be downloaded.
  attr_accessor :gp_project_url

  # @return [String] The path to the `.lproj` director of the base locale.
  attr_reader :base_localization_root

  # Initializes a new LocalizableSource instance.
  #
  # @param source_paths [Array<String>] The paths to the source files that contain localizable strings.
  # @param localizations_root [String] The parent directory containing the `.lproj` folders.
  # @param base_locale [String] The two-character locale that serves as the base local for localization.
  # @param gp_project_url [String, nil] Optional URL to the translation management system or project repository.
  # @raise [ArgumentError] if source_paths or localizations_root is nil.
  #
  def initialize(source_paths:, localizations_root:, base_locale: 'en', gp_project_url: nil)
    raise ArgumentError, 'source_paths cannot be nil' if source_paths.nil?
    raise ArgumentError, 'localizations_root cannot be nil' if localizations_root.nil?

    @source_paths = source_paths
    @localizations_root = localizations_root
    @base_locale = base_locale
    @gp_project_url = gp_project_url
    @base_localization_root = File.join(localizations_root, "#{base_locale}.lproj")
  end

  # Retrieves a list of all `.strings` files located in the base localization directory.
  #
  # @return [Array<String>] An array of `.strings` files in the base localization directory.
  #
  def base_localization_strings_paths
    Dir.glob(File.join(@base_localization_root, '*.strings'))
  end
end
