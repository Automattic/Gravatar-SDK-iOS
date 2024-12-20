.PHONY: all clean run swiftlint-check-version swiftlint-remove-old swiftlint-install

# To see how to drive this makefile use:
#
#   % make help

# Cache
# No spaces allowed
SWIFTFORMAT_CACHE = ~/Library/Caches/com.charcoaldesign.swiftformat

# The following values can be changed here, or passed on the command line.
OPENAPI_GENERATOR_DOCKER_IMAGE ?= openapitools/openapi-generator-cli
OPENAPI_GENERATOR_GIT_TAG ?= v7.5.0
OUTPUT_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/Sources/Gravatar/OpenApi/Generated

OPENAPI_PROJECT_NAME ?= GravatarOpenAPIClient
OPENAPI_REL_DIR ?= openapi
OPENAPI_DIR ?= $(CURRENT_MAKEFILE_DIR)/$(OPENAPI_REL_DIR)
OPENAPI_GENERATED_DIR ?= $(CURRENT_MAKEFILE_DIR)/openapi/$(OPENAPI_PROJECT_NAME)
OPENAPI_CLIENT_PROPERTIES ?= projectName=$(OPENAPI_PROJECT_NAME),useSPMFileStructure=true

# SwiftLint Configuration
SWIFTLINT_VERSION := 0.57.1
SWIFTLINT_DOWNLOAD_URL := https://github.com/realm/SwiftLint/releases/download/$(SWIFTLINT_VERSION)/portable_swiftlint.zip
SWIFTLINT_INSTALL_PATH := ./SwiftLint
SWIFTLINT_BINARY_PATH := $(SWIFTLINT_INSTALL_PATH)/swiftlint
SWIFTLINT_TEMP_DIR := /tmp/swiftlint_install
SWIFTLINT_CACHE_DIR := $(SWIFTLINT_INSTALL_PATH)/cache
SWIFTLINT_ZIP_FILE := portable_swiftlint_$(SWIFTLINT_VERSION).zip

# Derived values (don't change these).
CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(CURRENT_MAKEFILE_PATH)))

SCHEME_DEMO = "Gravatar Demo"

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

build-demo: bundle-install
	bundle exec fastlane build_demo scheme:$(SCHEME_DEMO)

build-demo-for-distribution: fetch-code-signing check-build-number setup-secrets
	bundle exec fastlane build_demo_for_distribution \
		scheme:$(SCHEME_DEMO) \
		build_number:$(BUILD_NUMBER)

check-build-number:
ifndef BUILD_NUMBER
	@echo "BUILD_NUMBER not set in the environment. Will default to 0."
	override BUILD_NUMBER = 0
endif

bundle-install:
	bundle install

fetch-code-signing: bundle-install
	bundle exec fastlane configure_code_signing

setup-secrets: bundle-install
	bundle exec fastlane run configure_apply

swiftformat: # Automatically find and fixes lint issues
	swift package plugin \
		--allow-writing-to-package-directory \
		--allow-writing-to-directory $(SWIFTFORMAT_CACHE) \
		swiftformat

lint: # Use swiftformat to warn about format issues
	swift package plugin \
		--allow-writing-to-package-directory \
		--allow-writing-to-directory $(SWIFTFORMAT_CACHE) \
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

install-and-generate: $(OPENAPI_GENERATOR_CLONE_DIR) # Clones and setup the openapi-generator.
	"$(OPENAPI_GENERATOR_CLONE_DIR)"/run-in-docker.sh mvn package
	make generate

generate: $(OPENAPI_GENERATED_DIR) # Generates the open-api model
	sed -i '' 's|components/schemas/Rating|components/schemas/AvatarRating|g' $(OPENAPI_DIR)/openapi.yaml
	sed -i '' 's| Rating:| AvatarRating:|g' $(OPENAPI_DIR)/openapi.yaml
	rm -rf "$(OPENAPI_GENERATED_DIR)"/* && \
	docker run --rm \
	-v $(OPENAPI_DIR):/local openapitools/openapi-generator-cli:"$(OPENAPI_GENERATOR_GIT_TAG)" generate \
	-i /local/openapi.yaml \
	-o /local/GravatarOpenAPIClient \
	-t /local/templates \
	-g swift5 \
	-p packageName=Gravatar \
	--additional-properties=useJsonEncodable=false,readonlyProperties=true,$(OPENAPI_CLIENT_PROPERTIES) && \
	rsync -av --delete "$(OPENAPI_GENERATED_DIR)/Sources/$(OPENAPI_PROJECT_NAME)/Models/" "$(OUTPUT_DIRECTORY)/" && \
	swift ./access-control-modifier.swift && \
	make swiftformat && \
    echo "DONE! 🎉"

generate-strings: bundle-install
	bundle exec fastlane generate_strings

download-strings: bundle-install
	bundle exec fastlane download_localized_strings

swiftlint-check-version: # Checks if SwiftLint is installed and the version matches
	@if [ -x "$(SWIFTLINT_BINARY_PATH)" ]; then \
		INSTALLED_VERSION=`$(SWIFTLINT_BINARY_PATH) --version`; \
		if [ "$$INSTALLED_VERSION" = "$(SWIFTLINT_VERSION)" ]; then \
			echo "SwiftLint version $(SWIFTLINT_VERSION) is already installed."; \
			exit 0; \
		else \
			echo "SwiftLint version $$INSTALLED_VERSION is installed, but $(SWIFTLINT_VERSION) is required."; \
			$(MAKE) swiftlint-remove-old; \
			false ; \
		fi \
	else \
		echo "SwiftLint is not installed."; \
		false; \
	fi

swiftlint-remove-old: # Remove the currently installed SwiftLint
	@if [ -f "$(SWIFTLINT_INSTALL_PATH)" ]; then \
		echo "Removing old SwiftLint version..."; \
		rm -f $(SWIFTLINT_INSTALL_PATH); \
		echo "Old SwiftLint removed."; \
	else \
		echo "No existing SwiftLint installation found."; \
	fi

swiftlint-install: # Download and install SwiftLint
	-@make swiftlint-check-version || make $(SWIFTLINT_INSTALL_PATH)

$(SWIFTLINT_INSTALL_PATH): validate-dependencies $(SWIFTLINT_ZIP_FILE)
	@echo "Installing SwiftLint version $(SWIFTLINT_VERSION) to $(SWIFTLINT_INSTALL_PATH)..."
	@mkdir -p "$(SWIFTLINT_TEMP_DIR)"
	@unzip -o "$(SWIFTLINT_CACHE_DIR)/$(SWIFTLINT_ZIP_FILE)" -d $(SWIFTLINT_TEMP_DIR)
	@mv $(SWIFTLINT_TEMP_DIR)/swiftlint $(SWIFTLINT_INSTALL_PATH)
	@chmod a+x $(SWIFTLINT_BINARY_PATH)
	@echo "SwiftLint version $(SWIFTLINT_VERSION) successfully installed at $(SWIFTLINT_INSTALL_PATH)."

$(SWIFTLINT_ZIP_FILE): validate-dependencies
	@echo "Checking cache for SwiftLint version $(SWIFTLINT_VERSION)..."
	@if [ ! -f "$(SWIFTLINT_CACHE_DIR)/$(SWIFTLINT_ZIP_FILE)" ]; then \
		mkdir -p "$(SWIFTLINT_CACHE_DIR)" \
		echo "SwiftLint version $(SWIFTLINT_VERSION) not found in cache. Downloading..."; \
		curl -L $(SWIFTLINT_DOWNLOAD_URL) -o "$(SWIFTLINT_CACHE_DIR)/$(SWIFTLINT_ZIP_FILE)" || { echo "Download failed!"; exit 1; }; \
	else \
		echo "SwiftLint version $(SWIFTLINT_VERSION) found in cache. Using cached file."; \
	fi

clean-generated:  # Delete the output directory used for generated sources.
	@echo 'Delete entire directory: $(OUTPUT_DIRECTORY)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OUTPUT_DIRECTORY)"

clean:  # Clean everything, including the checkout of swift-openapi-generator.
	@echo 'Delete checkout of openapi-generator $(OPENAPI_GENERATOR_CLONE_DIR)? [y/N] ' && read ans && [ $${ans:-N} = y ] && \
		rm -rf "$(OPENAPI_GENERATOR_CLONE_DIR)" || echo "Skipped deleting $(OPENAPI_GENERATOR_CLONE_DIR)"
	@echo 'Delete SwiftLint installation $(SWIFTLINT_INSTALL_PATH)? [y/N] ' && read ans && [ $${ans:-N} = y ] && \
		rm -rf "$(SWIFTLINT_INSTALL_PATH)" || echo "Skipped deleting $(SWIFTLINT_INSTALL_PATH)"
	@rm -rf "$(SWIFTLINT_CACHE_DIR)"
	@rm -rf "$(SWIFTLINT_TEMP_DIR)"

dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "OPENAPI_GENERATOR_DOCKER_IMAGE = $(OPENAPI_GENERATOR_DOCKER_IMAGE)"
	@echo "OPENAPI_GENERATOR_GIT_TAG = $(OPENAPI_GENERATOR_GIT_TAG)"
	@echo "OPENAPI_DIR = $(OPENAPI_DIR)"
	@echo "OPENAPI_GENERATED_DIR = $(OPENAPI_GENERATED_DIR)"
	@echo "OPENAPI_CLIENT_PROPERTIES = $(OPENAPI_CLIENT_PROPERTIES)"
	@echo "OUTPUT_DIRECTORY = $(OUTPUT_DIRECTORY)"
	@echo "SWIFTLINT_INSTALL_PATH = $(SWIFTLINT_INSTALL_PATH)"
	@echo "SWIFTLINT_CACHE_DIR = $(SWIFTLINT_CACHE_DIR)"
	@echo "SWIFTLINT_ZIP_FILE = $(SWIFTLINT_ZIP_FILE)"
	@echo "SWIFTLINT_BINARY_PATH = $(SWIFTLINT_BINARY_PATH)"

$(OPENAPI_GENERATED_DIR):
	mkdir -p "$@"

validate-dependencies:
	@command -v curl > /dev/null || { echo "curl is required but not installed."; exit 1; }
	@command -v unzip > /dev/null || { echo "unzip is required but not installed."; exit 1; }