# frozen_string_literal: true

require 'spec_helper'

INSTALL_PATH = '/tmp/swiftlint_test_install'
TARGET_VERSION = '0.51.0'

# rubocop:disable Metrics/BlockLength
describe Fastlane::Actions::InstallSwiftlintAction do
  let(:params) do
    {
      owner: 'realm',
      repo: 'SwiftLint',
      version: TARGET_VERSION,
      install_path: INSTALL_PATH
    }
  end

  let(:latest_version_response) { { 'tag_name' => TARGET_VERSION }.to_json }
  let(:latest_release_url) { 'https://api.github.com/repos/realm/SwiftLint/releases/latest' }
  let(:target_version_url) { "https://api.github.com/repos/realm/SwiftLint/releases/tags/#{TARGET_VERSION}" }
  let(:portable_swiftlint_url) { "https://github.com/realm/SwiftLint/releases/download/#{TARGET_VERSION}/portable_swiftlint.zip" }

  before do
    allow(FastlaneCore::UI).to receive(:message)
    allow(FastlaneCore::UI).to receive(:success)
    allow(FastlaneCore::UI).to receive(:important)
    allow(FastlaneCore::UI).to receive(:user_error!)
    FileUtils.rm_rf(params[:install_path]) # Ensure a clean slate for each test
  end

  describe '#run' do
    before do
      allow(described_class).to receive(:download_swiftlint_if_needed)
      allow(described_class).to receive(:install_swiftlint)
    end

    context 'when the correct version is already installed' do
      before do
        allow(described_class).to receive(:swiftlint_installed?).and_return(true)
      end

      it 'skips download' do
        described_class.run(params)
        expect(described_class).not_to have_received(:download_swiftlint_if_needed)
      end

      it 'skips installation' do
        described_class.run(params)
        expect(described_class).not_to have_received(:install_swiftlint)
      end
    end

    context 'when SwiftLint is not installed' do
      before do
        allow(described_class).to receive(:swiftlint_installed?).and_return(false)
      end

      it 'downloads SwiftLint' do
        described_class.run(params)
        expect(described_class).to have_received(:download_swiftlint_if_needed)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'installs SwiftLint' do
        # Stub the GitHub API request
        stub_request(:get, target_version_url)
          .to_return(
            status: 200,
            body: {
              assets: [
                {
                  name: 'portable_swiftlint.zip',
                  browser_download_url: portable_swiftlint_url
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        # Stub the SwiftLint file download
        stub_request(:get, portable_swiftlint_url)
          .to_return(
            status: 200,
            body: 'dummy file content',
            headers: { 'Content-Type' => 'application/zip' }
          )

        described_class.run(params)

        expect(described_class).to have_received(:install_swiftlint)
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#swiftlint_installed?' do
    it 'returns true if the correct version is installed' do
      swiftlint_binary = setup_swiftlint_binary(TARGET_VERSION)
      allow(described_class).to receive(:run_command).with("#{File.join(INSTALL_PATH, 'bin', 'swiftlint')} --version").and_return("#{TARGET_VERSION}\n")
      result = described_class.swiftlint_installed?(swiftlint_binary, TARGET_VERSION)
      expect(result).to be_truthy
    end

    it 'returns false if no binary is installed' do
      result = described_class.swiftlint_installed?('/nonexistent/path', TARGET_VERSION)
      expect(result).to be_falsey
    end
  end

  describe '#fetch_latest_release_tag' do
    it 'fetches the latest SwiftLint release tag from GitHub' do
      stub_request(:get, latest_release_url)
        .to_return(status: 200, body: latest_version_response)

      result = described_class.fetch_latest_release_tag
      expect(result).to eq(TARGET_VERSION)
    end

    it 'returns a UI User Error if the request fails' do
      stub_request(:get, latest_release_url)
        .to_return(status: [404, 'Not Found'])

      allow(FastlaneCore::UI).to receive(:user_error!)

      described_class.fetch_latest_release_tag

      expect(FastlaneCore::UI).to have_received(:user_error!).with('Failed to fetch the latest SwiftLint version: 404 Not Found')
    end
  end

  describe '#download_file' do
    let(:destination) { File.join(Dir.tmpdir, 'swiftlint.zip') }

    after do
      FileUtils.rm_f(destination)
    end

    it 'downloads a file and writes it to the specified location' do
      stub_request(:get, portable_swiftlint_url)
        .to_return(status: 200, body: 'dummy zip content')

      described_class.download_file(
        portable_swiftlint_url,
        destination
      )

      expect(File.read(destination)).to eq('dummy zip content')
    end

    it 'follows redirects' do
      stub_request(:get, portable_swiftlint_url)
        .to_return(status: 302, headers: { 'Location' => 'https://example.com/redirected.zip' })

      stub_request(:get, 'https://example.com/redirected.zip')
        .to_return(status: 200, body: 'redirected content')

      described_class.download_file(
        portable_swiftlint_url,
        destination
      )

      expect(File.read(destination)).to eq('redirected content')
    end

    it 'retries when rate limited (429 Too Many Requests)' do
      stub_request(:get, portable_swiftlint_url)
        .to_return(status: 429, headers: { 'Retry-After' => '1' })
        .then.to_return(status: 429, headers: { 'Retry-After' => '1' })
        .then.to_return(status: 200, body: latest_version_response)

      described_class.download_file(
        portable_swiftlint_url,
        destination
      )

      expect(File.read(destination)).to eq(latest_version_response)
    end

    it 'raises an error if the specified asset is not found' do
      response_body = { 'tag_name' => TARGET_VERSION, 'assets' => [] }.to_json
      stub_request(:get, target_version_url)
        .to_return(status: 200, body: response_body)

      expect do
        described_class.fetch_browser_download_url(TARGET_VERSION, 'nonexistent_asset.zip')
      end.to raise_error("Failed to fetch browser download URL: Asset 'nonexistent_asset.zip' not found for release #{TARGET_VERSION}")
    end
  end
end
# rubocop:enable Metrics/BlockLength

def setup_swiftlint_binary(version)
  binary_path = File.join(params[:install_path], 'bin', 'swiftlint')
  FileUtils.mkdir_p(File.dirname(binary_path))
  FileUtils.touch(binary_path)
  allow(File).to receive(:executable?).with(binary_path).and_return(true)
  allow(Kernel).to receive(:`).with("#{binary_path} --version").and_return("#{version}\n")
  binary_path
end
