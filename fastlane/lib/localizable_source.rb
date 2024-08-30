# frozen_string_literal: true

# Represents a localizable source for generating strings and downloading localizations from GlotPress.
#
# Example:
#
#   localizable = LocalizableSource.new(
#     source_paths: ['/path/to/source1', '/path/to/source2'],
#     localizations_root: '/path/to/localizations',
#     gp_project_url: 'https://example.com/project'
#   )
#
#   puts localizable.base_localization_strings
#   # Output: /path/to/localizations/en.lproj/Localizable.strings
#
#   puts localizable.base_localization_strings(base_locale: 'fr')
#   # Output: /path/to/localizations/fr.lproj/Localizable.strings
#
class LocalizableSource
  # @return [Array<String>] An array of paths where source files related to localization are stored.
  # This can include multiple directories where localized resources are kept.
  attr_accessor :source_paths

  # @return [String] The root directory for localization files.
  attr_accessor :localizations_root

  # @return [String, nil] An optional URL to the translation management system or project repository.
  # If `nil`, base localization files can be generated, but no localizations can be downloaded.
  attr_accessor :gp_project_url

  # Initializes a new LocalizableSource instance.
  #
  # @param source_paths [Array<String>] The paths to the source files.
  # @param localizations_root [String] The root directory for localization files.
  # @param gp_project_url [String, nil] Optional URL to the translation management system or project repository.
  # @raise [ArgumentError] if source_paths or localizations_root is nil.

  def initialize(source_paths:, localizations_root:, gp_project_url: nil)
    raise ArgumentError, 'source_paths cannot be nil' if source_paths.nil?
    raise ArgumentError, 'localizations_root cannot be nil' if localizations_root.nil?

    @source_paths = source_paths
    @localizations_root = localizations_root
    @gp_project_url = gp_project_url
  end

  # Constructs the path to the base localization strings file.
  #
  # The method combines the localization root directory with the locale and table name to generate the path
  # to the base localization strings file.
  #
  # @param table_name [String] The name of the table for localization strings. Defaults to "Localizable".
  # @param base_locale [String] The base locale for localization. Defaults to 'en'.
  # @return [String] The path to the base localization strings file.

  def base_localization_strings(table_name: 'Localizable', base_locale: 'en')
    File.join(@localizations_root, "#{base_locale}.lproj", "#{table_name}.strings")
  end
end
