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
#
# Notice that there are other env vars that Fastlane supports for sync_code_signing (match).
# In particular, Fastlane supports providing the password to decrypt the repo via MATCH_PASSWORD rather than terminal prompt + keychain.
# CI environments must set that env var because they are not interactive.
# However, we don't list it here with the required env var to allow devs to provide the password via the default method, which is also more secure.
#
# See also https://docs.fastlane.tools/actions/match/
CODE_SIGNING_ENV_VARS = %w[
  MATCH_S3_ACCESS_KEY
  MATCH_S3_SECRET_ACCESS_KEY
].freeze
