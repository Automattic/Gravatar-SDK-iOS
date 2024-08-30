class LocalizableSource
  attr_accessor :source_paths, :localizations_root, :gp_project_url

  def initialize(source_paths:, localizations_root:, gp_project_url: nil)
    raise ArgumentError, "source_paths cannot be nil" if source_paths.nil?
    raise ArgumentError, "localizations_root cannot be nil" if localizations_root.nil?

    @source_paths = source_paths
    @localizations_root = localizations_root
    @gp_project_url = gp_project_url
  end

  def base_localization_strings(base_locale: 'en')
    File.join(@localizations_root, "#{base_locale}.lproj", 'Localizable.strings')
  end
end
