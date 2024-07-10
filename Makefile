.PHONY: all clean run

# To see how to drive this makefile use:
#
#   % make help

# Cache
# No spaces allowed
SWIFTFORMAT_CACHE = ~/Library/Caches/com.charcoaldesign.swiftformat

# The following values can be changed here, or passed on the command line.
OPENAPI_GENERATOR_GIT_URL ?= https://github.com/openapitools/openapi-generator
OPENAPI_GENERATOR_GIT_TAG ?= v7.5.0
OPENAPI_GENERATOR_CLONE_DIR ?= $(CURRENT_MAKEFILE_DIR)/openapi-generator
OPENAPI_YAML_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi/spec.yaml
MODEL_TEMPLATE_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi
OUTPUT_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/Sources/Gravatar/OpenApi/Generated
SECRETS_PATH=$(CURRENT_MAKEFILE_DIR)/Demo/Demo/Gravatar-Demo/Secrets.swift

# Derived values (don't change these).
CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(CURRENT_MAKEFILE_PATH)))


# If no target is specified, display help
.DEFAULT_GOAL := help

help:  # Display this help.
	@-+echo "Run make with one of the following targets:"
	@-+echo
	@-+grep -Eh "^[a-z-]+:.*#" $(CURRENT_MAKEFILE_PATH) | sed -E 's/^(.*:)(.*#+)(.*)/  \1 @@@ \3 /' | column -t -s "@@@"

dev: secrets # Open the package in xcode
	xed .

dev-demo: secrets # Open an xcode project with the package and a demo project
	xed Demo/

test: bundle-install
	bundle exec fastlane test

build-demo: secrets build-demo-swift build-demo-swiftui

build-demo-swift: bundle-install
	bundle exec fastlane build_demo scheme:Gravatar-Demo

build-demo-swiftui: bundle-install
	bundle exec fastlane build_demo scheme:Gravatar-SwiftUI-Demo

bundle-install:
	bundle install

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

secrets: # Creates the Secrets file in the Demo app.
	if [ ! -f $(SECRETS_PATH) ]; then \
		touch $(SECRETS_PATH); \
		echo "let apiKey: String? = nil" > $(SECRETS_PATH); \
	fi

install-and-generate: $(OPENAPI_GENERATOR_CLONE_DIR) # Clones and setup the openapi-generator.
	"$(OPENAPI_GENERATOR_CLONE_DIR)"/run-in-docker.sh mvn package
	make generate

generate: $(OUTPUT_DIRECTORY) # Generates the open-api model
	cp "$(OPENAPI_YAML_PATH)" "$(OPENAPI_GENERATOR_CLONE_DIR)"/openapi.yaml
	mkdir -p "$(OPENAPI_GENERATOR_CLONE_DIR)"/templates
	cp "$(MODEL_TEMPLATE_PATH)"/*.mustache "$(OPENAPI_GENERATOR_CLONE_DIR)"/templates/
	"$(OPENAPI_GENERATOR_CLONE_DIR)"/run-in-docker.sh generate -i openapi.yaml \
    --global-property models \
    -t templates \
    -g swift5 \
    -o ./generated \
    -p packageName=Gravatar \
	--additional-properties=useJsonEncodable=false,readonlyProperties=true && \
    cp "$(OPENAPI_GENERATOR_CLONE_DIR)"/generated/OpenAPIClient/Classes/OpenAPIs/Models/* "$(OUTPUT_DIRECTORY)" && \
    make swiftformat && \
    echo "DONE! 🎉"

clean-generated:  # Delete the output directory used for generated sources.
	@echo 'Delete entire directory: $(OUTPUT_DIRECTORY)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OUTPUT_DIRECTORY)"

clean:  # Clean everything, including the checkout of swift-openapi-generator.
	@echo 'Delete checkout of openapi-generator $(OPENAPI_GENERATOR_CLONE_DIR)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OPENAPI_GENERATOR_CLONE_DIR)"


dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "OPENAPI_GENERATOR_GIT_URL = $(OPENAPI_GENERATOR_GIT_URL)"
	@echo "OPENAPI_GENERATOR_GIT_TAG = $(OPENAPI_GENERATOR_GIT_TAG)"
	@echo "OPENAPI_GENERATOR_CLONE_DIR = $(OPENAPI_GENERATOR_CLONE_DIR)"
	@echo "OPENAPI_YAML_PATH = $(OPENAPI_YAML_PATH)"
	@echo "OUTPUT_DIRECTORY = $(OUTPUT_DIRECTORY)"

$(OPENAPI_GENERATOR_CLONE_DIR):
	git \
		-c advice.detachedHead=false \
		clone \
		--branch "$(OPENAPI_GENERATOR_GIT_TAG)" \
		--depth 1 \
		"$(OPENAPI_GENERATOR_GIT_URL)" \
		$@

$(OUTPUT_DIRECTORY):
	mkdir -p "$@"
