.PHONY: all clean run

# To see how to drive this makefile use:
#
#   % make help

# Cache
SWIFTFORMAT_CACHE = ~/Library/Caches/com.charcoaldesign.swiftformat

# The following values can be changed here, or passed on the command line.
SWIFT_OPENAPI_GENERATOR_GIT_URL ?= https://github.com/apple/swift-openapi-generator
SWIFT_OPENAPI_GENERATOR_GIT_TAG ?= 1.0.0
SWIFT_OPENAPI_GENERATOR_CLONE_DIR ?= $(CURRENT_MAKEFILE_DIR)/.swift-openapi-generator
SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION ?= debug
OPENAPI_YAML_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi.yaml
OPENAPI_GENERATOR_CONFIG_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi-generator-config.yaml
OUTPUT_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/Sources/Gravatar/OpenApi/Generated

# Derived values (don't change these).
CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(CURRENT_MAKEFILE_PATH)))
SWIFT_OPENAPI_GENERATOR_BIN := $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)/.build/$(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)/swift-openapi-generator

# If no target is specified, display help
.DEFAULT_GOAL := help

help:  # Display this help.
	@-+echo "Run make with one of the following targets:"
	@-+echo
	@-+grep -Eh "^[a-z-]+:.*#" $(CURRENT_MAKEFILE_PATH) | sed -E 's/^(.*:)(.*#+)(.*)/  \1 @@@ \3 /' | column -t -s "@@@"

dev: # Open the package in xcode
	xed .

dev-demo: # Open an xcode project with the package and a demo project
	xed Demo/

test: bundle-install
	bundle exec fastlane test

build-demo: build-demo-swift build-demo-swiftui
	
build-demo-swift: bundle-install
	bundle exec fastlane build_demo scheme:Gravatar-Demo

build-demo-swiftui: bundle-install
	bundle exec fastlane build_demo scheme:Gravatar-SwiftUI-Demo

bundle-install:
	bundle install

swiftformat: # Automatically find and fixes lint issues
	swift package plugin \
		--allow-writing-to-package-directory \
		--allow-writing-to-directory "$(SWIFTFORMAT_CACHE)" \
		swiftformat

lint: # Use swiftformat to warn about format issues
	swift package plugin \
		--allow-writing-to-package-directory \
		--allow-writing-to-directory "$(SWIFTFORMAT_CACHE)" \
		swiftformat \
		--lint

validate-pod: bundle-install
	# For some reason this fixes a failure in `lib lint`
	# https://github.com/Automattic/buildkite-ci/issues/7
	xcrun simctl list >> /dev/null
	bundle exec pod lib lint \
		--include-podspecs="*.podspec" \
		--verbose --fail-fast

update-example-snapshots:
	for filePath in ./Sources/GravatarUI/GravatarUI.docc/Resources/ProfileExamples/*; \
	do rm $$filePath; done
	cp ./Tests/GravatarUITests/__Snapshots__/ProvileViewSnapshots/* ./Sources/GravatarUI/GravatarUI.docc/Resources/ProfileExamples
	# Append @2x to the file name.
	cd ./Sources/GravatarUI/GravatarUI.docc/Resources/ProfileExamples && \
	for filePath in *; do name=$${filePath%.*}; mv $$filePath $${name//-dark/~dark}@2x$${filePath#$$name}; done


generate: $(SWIFT_OPENAPI_GENERATOR_BIN) $(OPENAPI_YAML_PATH) $(OPENAPI_GENERATOR_CONFIG_PATH) $(OUTPUT_DIRECTORY)  # Generate the sources using swift-openapi-generator.
	$< generate \
		--config "$(OPENAPI_GENERATOR_CONFIG_PATH)" \
		--output-directory "$(OUTPUT_DIRECTORY)" \
		"$(OPENAPI_YAML_PATH)"

clean-generated:  # Delete the output directory used for generated sources.
	@echo 'Delete entire directory: $(OUTPUT_DIRECTORY)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OUTPUT_DIRECTORY)"

clean-all: clean  # Clean everything, including the checkout of swift-openapi-generator.
	@echo 'Delete checkout of swift-openapi-generator $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)"


dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "SWIFT_OPENAPI_GENERATOR_GIT_URL = $(SWIFT_OPENAPI_GENERATOR_GIT_URL)"
	@echo "SWIFT_OPENAPI_GENERATOR_GIT_TAG = $(SWIFT_OPENAPI_GENERATOR_GIT_TAG)"
	@echo "SWIFT_OPENAPI_GENERATOR_CLONE_DIR = $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)"
	@echo "SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION = $(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)"
	@echo "SWIFT_OPENAPI_GENERATOR_BIN = $(SWIFT_OPENAPI_GENERATOR_BIN)"
	@echo "OPENAPI_YAML_PATH = $(OPENAPI_YAML_PATH)"
	@echo "OPENAPI_GENERATOR_CONFIG_PATH = $(OPENAPI_GENERATOR_CONFIG_PATH)"
	@echo "OUTPUT_DIRECTORY = $(OUTPUT_DIRECTORY)"

$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR):
	git \
		-c advice.detachedHead=false \
		clone \
		--branch "$(SWIFT_OPENAPI_GENERATOR_GIT_TAG)" \
		--depth 1 \
		"$(SWIFT_OPENAPI_GENERATOR_GIT_URL)" \
		$@

$(SWIFT_OPENAPI_GENERATOR_BIN): $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)
	swift \
		build \
		--package-path "$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)" \
		--configuration "$(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)" \
		--product swift-openapi-generator

$(OUTPUT_DIRECTORY):
	mkdir -p "$@"
