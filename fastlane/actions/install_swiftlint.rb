require 'fileutils'
require 'open3'
require 'open-uri'
require 'zip'

module Fastlane
  module Actions
    class InstallSwiftlintAction < Action
      def self.run(params)
        # Parameters
        swiftlint_version = params[:version]
        install_dir = params[:install_path]

        bin_dir = File.join(install_dir, 'bin')
        cache_dir = File.join(install_dir, 'cache')
        temp_dir = "/tmp/swiftlint_install"
        install_binary_path = File.join(bin_dir, 'swiftlint')

        download_version = swiftlint_version == "latest" ? fetch_latest_release_tag : swiftlint_version
        zip_file = File.join(cache_dir, "portable_swiftlint_#{download_version}.zip")
        download_url = "https://github.com/realm/SwiftLint/releases/download/#{download_version}/portable_swiftlint.zip"

        # Ensure directories exist
        FileUtils.mkdir_p(bin_dir)
        FileUtils.mkdir_p(cache_dir)
        FileUtils.mkdir_p(temp_dir)

        # Check if SwiftLint is already installed
        return if swiftlint_installed?(install_binary_path, download_version)

        # Download SwiftLint if not cached
        unless File.exist?(zip_file)
          UI.message("Downloading SwiftLint version #{download_version}...")
          download_swiftlint(download_url, zip_file)
        else
          UI.message("Using cached SwiftLint version #{download_version}")
        end

        # Remove old SwiftLint if needed
        if File.exist?(install_binary_path)
            UI.important("Removing old SwiftLint version...")
            FileUtils.rm_f(install_binary_path)
        end

        # Install SwiftLint
        UI.message("Installing SwiftLint version #{download_version}...")
        install_swiftlint(zip_file, temp_dir, install_binary_path)
        UI.success("SwiftLint version #{download_version} installed successfully at #{install_dir}")
      end

      def self.swiftlint_installed?(install_binary_path, expected_version)
        return false unless File.exist?(install_binary_path) && File.executable?(install_binary_path)
      
        installed_version = `#{install_binary_path} --version`.strip rescue nil
        if installed_version == expected_version
          UI.success("SwiftLint version #{installed_version} is installed")
          true
        else
          UI.message("Expected SwiftLint version #{expected_version}, but found #{installed_version}")
          false
        end
      end

      def self.download_swiftlint(url, destination)
        URI.open(url) do |download|
          File.open(destination, "wb") do |file|
            file.write(download.read)
          end
        end
      rescue => e
        UI.user_error!("Failed to download SwiftLint: #{e.message}")
      end

      def self.install_swiftlint(zip_file, temp_dir, install_binary_path)
        begin
          # Extract the zip file
          Zip::File.open(zip_file) do |zip|
            zip.each do |entry|
                target_path = File.join(temp_dir, entry.name)
                entry.extract(target_path) { true } rescue UI.user_error!("Failed to extract #{entry.name}")
            end
          end

          # Move the binary to the install path
          swiftlint_binary = File.join(temp_dir, "swiftlint")
          FileUtils.mv(swiftlint_binary, install_binary_path)
          FileUtils.chmod("+x", install_binary_path)
        rescue => e
          UI.user_error!("Failed to install SwiftLint: #{e.message}")
        ensure
          FileUtils.rm_rf(temp_dir) # Clean up temp directory
        end
      end

      def self.fetch_latest_release_tag
        UI.message("Fetching the latest SwiftLint version...")
        api_url = "https://api.github.com/repos/realm/SwiftLint/releases/latest"
        latest_version = nil

        begin
          response = URI.open(api_url).read
          json = JSON.parse(response)
          latest_version = json["tag_name"]
        rescue => e
          UI.user_error!("Failed to fetch the latest SwiftLint version: #{e.message}")
        end

        UI.message("Latest SwiftLint version: #{latest_version}")
        latest_version
      end

      def self.description
        "This action installs SwiftLint, checking for the desired version and downloading if necessary. \
         It uses a cache directory to avoid redundant downloads and ensures proper binary installation."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: "The version of SwiftLint to install (default: 'latest')",
            default_value: "latest",
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :install_path,
            description: "The installation path for the SwiftLint binary",
            optional: false
          )
        ]
      end

      def self.authors
        ["Automattic"]
      end

      def self.is_supported?(platform)
        [:mac].include?(platform)
      end
    end
  end
end