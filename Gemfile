# frozen_string_literal: true

source 'https://rubygems.org'

gem 'cocoapods', '~> 1.14.3'
gem 'fastlane', '~> 2.222'
gem 'fastlane-plugin-appcenter', '~> 2.1'
gem 'fastlane-plugin-wpmreleasetoolkit', '~> 12.0'
gem 'rubocop', '~> 1.65'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
