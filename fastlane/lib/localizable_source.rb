# frozen_string_literal: true

# LocalizableSource
#
# The `LocalizableSource` class represents a localizable source for generating
# strings and downloading localizations from GlotPress.
#
# Attributes:
# - `@source_paths` [Array<String>]
#   An array of paths where source files related to localization are stored.
#   This can include multiple directories where localized resources are kept.
#
# - `@localizations_root` [String]
#   The root directory path where the localization files are stored.
#   This is the base path that will be combined with specific locale directories
#   to generate paths to the localization files.
#
# - `@gp_project_url` [String, nil]
#   The URL of the related GlotPress project associated with the localization
#   files.
#
# Methods:
# - `initialize(source_paths:, localizations_root:, gp_project_url: nil)`:
#   Creates a new instance of `LocalizableSource`.
#   - `source_paths`: (Array<String>) An array of paths where source files are located. This argument
#     is required and cannot be `nil`.
#   - `localizations_root`: (String) The root path for localization files. This argument is required
#     and cannot be `nil`.
#   - `gp_project_url`: (String, nil) The URL to the GlotPress project or similar. This argument is
#     optional.
#   - Raises: `ArgumentError` if either `source_paths` or `localizations_root` is `nil`.
#
# - `base_localization_strings(base_locale: 'en')`:
#   Generates the file path to the `Localizable.strings` file for a given locale.
#   - `base_locale`: (String) The locale code (e.g., 'en', 'fr', 'es') for which to generate the path.
#     Defaults to `'en'`.
#   - Returns: (String) The full path to the `Localizable.strings` file for the specified locale.
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
  attr_accessor :source_paths, :localizations_root, :gp_project_url

  def initialize(source_paths:, localizations_root:, gp_project_url: nil)
    raise ArgumentError, 'source_paths cannot be nil' if source_paths.nil?
    raise ArgumentError, 'localizations_root cannot be nil' if localizations_root.nil?

    @source_paths = source_paths
    @localizations_root = localizations_root
    @gp_project_url = gp_project_url
  end

  def base_localization_strings(base_locale: 'en')
    File.join(@localizations_root, "#{base_locale}.lproj", 'Localizable.strings')
  end
end
