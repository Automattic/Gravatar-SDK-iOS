# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe Fastlane::Actions::InstallSwiftlintAction do
  let(:params) do
    {
      owner: 'realm',
      repo: 'SwiftLint',
      version: '0.51.0',
      install_path: '/tmp/swiftlint_test_install'
    }
  end

  let(:latest_version_response) { { 'tag_name' => '0.51.0' }.to_json }
  let(:latest_release_url) { 'https://api.github.com/repos/realm/SwiftLint/releases/latest' }
  let(:portable_swiftlint_url) { 'https://github.com/realm/SwiftLint/releases/download/0.51.0/portable_swiftlint.zip' }

  before(:each) do
    allow(FastlaneCore::UI).to receive(:message)
    allow(FastlaneCore::UI).to receive(:success)
    allow(FastlaneCore::UI).to receive(:important)
    allow(FastlaneCore::UI).to receive(:user_error!)
    FileUtils.rm_rf(params[:install_path]) # Ensure a clean slate for each test
  end

  describe '#run' do
    it 'skips installation if the correct version is already installed' do
      allow(Fastlane::Actions::InstallSwiftlintAction).to receive(:swiftlint_installed?).and_return(true)

      expect(Fastlane::Actions::InstallSwiftlintAction).not_to receive(:download_swiftlint_if_needed)
      expect(Fastlane::Actions::InstallSwiftlintAction).not_to receive(:install_swiftlint)

      Fastlane::Actions::InstallSwiftlintAction.run(params)
    end

    it 'downloads and installs SwiftLint if not installed' do
      allow(Fastlane::Actions::InstallSwiftlintAction).to receive(:swiftlint_installed?).and_return(false)
      allow(Fastlane::Actions::InstallSwiftlintAction).to receive(:download_swiftlint_if_needed)
      allow(Fastlane::Actions::InstallSwiftlintAction).to receive(:install_swiftlint)

      Fastlane::Actions::InstallSwiftlintAction.run(params)

      expect(Fastlane::Actions::InstallSwiftlintAction).to have_received(:download_swiftlint_if_needed)
      expect(Fastlane::Actions::InstallSwiftlintAction).to have_received(:install_swiftlint)
    end
  end

  describe '#swiftlint_installed?' do
    it 'returns true if the correct version is installed' do
      FileUtils.mkdir_p(File.join(params[:install_path], 'bin'))
      swiftlint_binary = File.join(params[:install_path], 'bin', 'swiftlint')
      FileUtils.touch(swiftlint_binary)
      allow(File).to receive(:executable?).with(swiftlint_binary).and_return(true)
      allow_any_instance_of(Object).to receive(:`).with("#{swiftlint_binary} --version").and_return("0.51.0\n")

      result = Fastlane::Actions::InstallSwiftlintAction.swiftlint_installed?(swiftlint_binary, '0.51.0')
      expect(result).to be_truthy
    end

    it 'returns false if no binary is installed' do
      result = Fastlane::Actions::InstallSwiftlintAction.swiftlint_installed?('/nonexistent/path', '0.51.0')
      expect(result).to be_falsey
    end
  end

  describe '#fetch_latest_release_tag' do
    it 'fetches the latest SwiftLint release tag from GitHub' do
      stub_request(:get, latest_release_url)
        .to_return(status: 200, body: latest_version_response)

      result = Fastlane::Actions::InstallSwiftlintAction.fetch_latest_release_tag
      expect(result).to eq('0.51.0')
    end

    it 'returns a UI User Error if the request fails' do
      stub_request(:get, latest_release_url)
        .to_return(status: [404, 'Not Found'])

      expect(FastlaneCore::UI).to receive(:user_error!).with('Failed to fetch the latest SwiftLint version: 404 Not Found')

      Fastlane::Actions::InstallSwiftlintAction.fetch_latest_release_tag
    end
  end

  describe '#download_file' do
    it 'downloads a file and writes it to the specified location' do
      stub_request(:get, portable_swiftlint_url)
        .to_return(status: 200, body: 'dummy zip content')

      destination = File.join(Dir.tmpdir, 'swiftlint.zip')
      Fastlane::Actions::InstallSwiftlintAction.download_file(
        portable_swiftlint_url,
        destination
      )

      expect(File.exist?(destination)).to be_truthy
      expect(File.read(destination)).to eq('dummy zip content')
    end

    it 'follows redirects' do
      stub_request(:get, portable_swiftlint_url)
        .to_return(status: 302, headers: { 'Location' => 'https://example.com/redirected.zip' })

      stub_request(:get, 'https://example.com/redirected.zip')
        .to_return(status: 200, body: 'redirected content')

      destination = File.join(Dir.tmpdir, 'swiftlint.zip')
      Fastlane::Actions::InstallSwiftlintAction.download_file(
        portable_swiftlint_url,
        destination
      )

      expect(File.exist?(destination)).to be_truthy
      expect(File.read(destination)).to eq("redirected content")
    end
  end
end
# rubocop:enable Metrics/BlockLength
