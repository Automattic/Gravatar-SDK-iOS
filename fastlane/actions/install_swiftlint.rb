# frozen_string_literal: true

require 'fileutils'
require 'net/http'
require 'json'
require 'zip'
require 'tmpdir'

module Fastlane
  module Actions
    # rubocop:disable Metrics/ClassLength
    # rubocop: disable Style/Documentation
    class InstallSwiftlintAction < Action
      def self.run(params)
        # Prepare paths and settings
        swiftlint_version, install_binary_path, zip_file = prepare_paths(params)

        # Skip if the correct version is already installed
        return if swiftlint_installed?(install_binary_path, swiftlint_version)

        # Download SwiftLint if needed
        download_swiftlint_if_needed(swiftlint_version, zip_file)

        # Install SwiftLint
        install_swiftlint(zip_file, install_binary_path)
      end

      def self.prepare_paths(params)
        swiftlint_version = params[:version]
        install_dir = params[:install_path]

        bin_dir = File.join(install_dir, 'bin')
        cache_dir = File.join(install_dir, 'cache')
        install_binary_path = File.join(bin_dir, 'swiftlint')

        download_version = swiftlint_version == 'latest' ? fetch_latest_release_tag : validate_version(swiftlint_version)
        zip_file = File.join(cache_dir, "portable_swiftlint_#{download_version}.zip")

        # Ensure directories exist
        FileUtils.mkdir_p(bin_dir)
        FileUtils.mkdir_p(cache_dir)

        [download_version, install_binary_path, zip_file]
      end

      def self.swiftlint_installed?(install_binary_path, expected_version)
        return false unless File.exist?(install_binary_path) && File.executable?(install_binary_path)

        installed_version = begin
          `#{install_binary_path} --version`.strip
        rescue StandardError
          nil
        end
        if installed_version == expected_version
          UI.success("SwiftLint version #{installed_version} is installed")
          true
        else
          UI.important("Expected SwiftLint version #{expected_version}, but found #{installed_version}")
          false
        end
      end

      def self.download_swiftlint_if_needed(version, zip_file)
        if File.exist?(zip_file)
          UI.message("Using cached SwiftLint version #{version}")
        else
          UI.message("Downloading SwiftLint version #{version}...")
          url = "https://github.com/realm/SwiftLint/releases/download/#{version}/portable_swiftlint.zip"
          download_file(url, zip_file)
        end
      end

      def self.download_file(url, destination)
        uri = URI.parse(url)

        response = fetch_http_response(uri)
        write_to_file(response, destination)
      rescue StandardError => e
        UI.user_error!("Failed to download SwiftLint: #{e.message}")
      end

      # rubocop:disable Metrics/AbcSize
      # Fetch the HTTP response, following redirects if needed
      def self.fetch_http_response(uri)
        loop do
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
            request = Net::HTTP::Get.new(uri)
            http.request(request)
          end

          case response
          when Net::HTTPSuccess
            return response
          when Net::HTTPRedirection
            new_location = response['location']
            uri = URI.parse(new_location)
          when Net::HTTPTooManyRequests
            retry_after = response['Retry-After']&.to_i || 5
            UI.message("Rate limited. Retrying after #{retry_after} seconds...")
            sleep(retry_after)
          else
            raise "Failed to fetch SwiftLint from #{uri}: #{response.code} #{response.message}"
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      # Write the HTTP response body to a file
      def self.write_to_file(response, destination)
        File.binwrite(destination, response.body)
        UI.success("Downloaded SwiftLint to #{destination}")
      end

      def self.install_swiftlint(zip_file, install_binary_path)
        temp_dir = Dir.mktmpdir('swiftlint_install')
        begin
          UI.message('Installing SwiftLint...')
          # Extract the zip file
          Zip::File.open(zip_file) do |zip|
            zip.each do |entry|
              entry.extract(File.join(temp_dir, entry.name)) { true }
            end
          end

          # Move the binary to the install path
          swiftlint_binary = File.join(temp_dir, 'swiftlint')
          FileUtils.mv(swiftlint_binary, install_binary_path)
          FileUtils.chmod('+x', install_binary_path)
          UI.success("SwiftLint installed successfully at #{install_binary_path}")
        ensure
          FileUtils.rm_rf(temp_dir) # Clean up temp directory
        end
      rescue StandardError => e
        UI.user_error!("Failed to install SwiftLint: #{e.message}")
      end

      def self.fetch_latest_release_tag
        UI.message('Fetching the latest SwiftLint version...')
        api_url = URI('https://api.github.com/repos/realm/SwiftLint/releases/latest')

        response = Net::HTTP.get(api_url)
        json = JSON.parse(response)
        latest_version = json['tag_name']

        UI.message("Latest SwiftLint version: #{latest_version}")
        latest_version
      rescue StandardError => e
        UI.user_error!("Failed to fetch the latest SwiftLint version: #{e.message}")
      end

      def self.validate_version(version)
        UI.user_error!("Invalid version format: #{version}. Use 'latest' or a valid semantic version (e.g., '0.51.0').") unless version.match?(/^\d+\.\d+\.\d+$/)
        version
      end

      #####################################################
      # Documentation
      #####################################################

      def self.description
        "This action installs SwiftLint, ensuring the specified version is present. \
         If 'latest' is specified as the version, it will download the most recent version available. \
         It avoids redundant downloads by using a cache directory and ensures proper binary installation. \
         For more details, visit: https://github.com/realm/SwiftLint"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: "The version of SwiftLint to install (default: 'latest')",
            default_value: 'latest',
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :install_path,
            description: 'The installation path for the SwiftLint binary',
            optional: false
          )
        ]
      end

      def self.authors
        ['Automattic']
      end

      def self.supported?(platform)
        [:mac].include?(platform)
      end
    end
    # rubocop:enable Style/Documentation
    # rubocop:enable Metrics/ClassLength
  end
end
