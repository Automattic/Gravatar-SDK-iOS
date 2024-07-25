# frozen_string_literal: true

def prompt_user_for_app_store_connect_credentials
  require 'credentials_manager'

  # If Fastlane cannot instantiate a user, it will ask the caller for the email.
  # Once we have it, we can set it as `FASTLANE_USER` in the environment so that the next commands will already have access to it.
  # Notice that the lifecycle of these ENV modifications is limited to the Fastlane run that invoked this method.
  #
  # Note: if the user is already available to `AccountManager`, setting it in the env is redundant, but Fastlane doesn't provide a way to check it so we have to do it anyway.
  ENV['FASTLANE_USER'] = CredentialsManager::AccountManager.new.user
end

CODE_SIGNING_STORAGE_OPTIONS = {
  storage_mode: 's3',
  s3_bucket: 'a8c-fastlane-match',
  s3_region: 'us-east-2'
}.freeze

# Required for sync_code_signing to authenticate with S3.
CODE_SIGNING_ENV_VARS = %w[
  MATCH_S3_ACCESS_KEY
  MATCH_S3_SECRET_ACCESS_KEY
  MATCH_PASSWORD
].freeze

# Required for app_store_connect_api_key to generate the key information to pass down the call chain.
ASC_API_KEY_ENV_VARS = %w[
  APP_STORE_CONNECT_API_KEY_KEY_ID
  APP_STORE_CONNECT_API_KEY_ISSUER_ID
  APP_STORE_CONNECT_API_KEY_KEY
].freeze
