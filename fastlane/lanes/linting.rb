# frozen_string_literal: true

SWIFTLINT_VERSION = '0.57.1'
SWIFTLINT_INSTALL_PATH = "SwiftLint"
SWIFTLINT_BINARY_PATH = "#{SWIFTLINT_INSTALL_PATH}/bin/swiftlint"

#################################################
# Lanes
#################################################
platform :ios do
    desc 'Installs and runs SwiftLint'
    lane :run_swiftlint do
        install_swiftlint(
        version: SWIFTLINT_VERSION,
        install_path: SWIFTLINT_INSTALL_PATH
        )

        swiftlint(
        mode: :lint,
        raise_if_swiftlint_error: true,
        quiet: true,
        executable: SWIFTLINT_BINARY_PATH
        )
    end
end