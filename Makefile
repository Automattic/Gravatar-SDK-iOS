.PHONY: all clean run swiftlint

# To see how to drive this makefile use:
#
#   % make help

# SwiftLint
SWIFTLINT_VERSION := $(shell awk -F': ' '/^swiftlint_version: / {print $$2}' .swiftlint.yml)
SWIFTLINT_DOCKER_BUILDER_NAME = swiftlint_builder

# SwiftFormat
SWIFTFORMAT_VERSION := $(shell awk '/^--minversion/ { print $$2 }' .swiftformat)

# The following values can be changed here, or passed on the command line.
OPENAPI_GENERATOR_DOCKER_IMAGE ?= openapitools/openapi-generator-cli
OPENAPI_GENERATOR_GIT_TAG ?= v7.5.0
OUTPUT_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/Sources/Gravatar/OpenApi/Generated

OPENAPI_PROJECT_NAME ?= GravatarOpenAPIClient
OPENAPI_REL_DIR ?= openapi
OPENAPI_DIR ?= $(CURRENT_MAKEFILE_DIR)/$(OPENAPI_REL_DIR)
OPENAPI_GENERATED_DIR ?= $(CURRENT_MAKEFILE_DIR)/openapi/$(OPENAPI_PROJECT_NAME)
OPENAPI_CLIENT_PROPERTIES ?= projectName=$(OPENAPI_PROJECT_NAME),useSPMFileStructure=true

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

build-demo-for-distribution: fetch-code-signing setup-secrets
	bundle exec fastlane build_demo_for_distribution scheme:$(SCHEME_DEMO)

bundle-install:
	bundle install

fetch-code-signing: bundle-install
	bundle exec fastlane configure_code_signing

setup-secrets: bundle-install
	bundle exec fastlane configure_secrets

swiftformat: check-docker # Automatically find and fixes lint issues
	@docker run --rm -v $(shell pwd):$(shell pwd) -w $(shell pwd) ghcr.io/nicklockwood/swiftformat:$(SWIFTFORMAT_VERSION) Sources Tests

swiftformat-lint: check-docker
	@docker run --rm -v $(shell pwd):$(shell pwd) -w $(shell pwd) ghcr.io/nicklockwood/swiftformat:$(SWIFTFORMAT_VERSION) Sources Tests --lint

swiftlint: docker-swiftlint-builder swiftlint-run # Sets up the buildx builder and runs the swiftlint command

docker-swiftlint-builder: check-docker # Create and use the Buildx builder because the SwiftLint docker image doesn't support Apple Silicon
	@if ! docker buildx inspect $(SWIFTLINT_DOCKER_BUILDER_NAME) >/dev/null 2>&1; then \
		docker buildx create --use --name $(SWIFTLINT_DOCKER_BUILDER_NAME); \
	else \
		docker buildx use $(SWIFTLINT_DOCKER_BUILDER_NAME); \
	fi

swiftlint-run: check-docker # Docker command to run swiftlint
	@docker run --rm --platform linux/amd64 -v $(shell pwd):$(shell pwd) -w $(shell pwd) ghcr.io/realm/swiftlint:$(SWIFTLINT_VERSION)

swiftlint-version:
	@if [ -z "$(SWIFTLINT_VERSION)" ]; then \
		echo "SwiftLint version not found in .swiftlint.yml"; \
	else \
		echo "SwiftLint version: $(SWIFTLINT_VERSION)"; \
	fi

lint: # Use swiftformat to warn about format issues
	@make swiftlint
	@make swiftformat-lint

update-example-snapshots:
	for filePath in ./Sources/GravatarUI/GravatarUI.docc/Resources/ProfileExamples/*; \
	do rm $$filePath; done
	cp ./Tests/GravatarUITests/__Snapshots__/ProvileViewSnapshots/* ./Sources/GravatarUI/GravatarUI.docc/Resources/ProfileExamples
	# Append @2x to the file name.
	cd ./Sources/GravatarUI/GravatarUI.docc/Resources/ProfileExamples && \
	for filePath in *; do name=$${filePath%.*}; mv $$filePath $${name//-dark/~dark}@2x$${filePath#$$name}; done

generate: check-docker $(OPENAPI_GENERATED_DIR) # Generates the open-api model
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

check-docker:
	@command -v docker >/dev/null 2>&1 || { echo "Error: Docker is not installed or not in PATH"; false; }
	@docker info >/dev/null 2>&1 || { echo "Error: Docker is installed but not running or accessible by the current user"; false; }

generate-strings: bundle-install
	bundle exec fastlane generate_strings

download-strings: bundle-install
	bundle exec fastlane download_localized_strings

clean-generated:  # Delete the output directory used for generated sources.
	@echo 'Delete entire directory: $(OUTPUT_DIRECTORY)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OUTPUT_DIRECTORY)"

clean:  # Clean everything, including the checkout of swift-openapi-generator.
	@echo 'Delete checkout of openapi-generator $(OPENAPI_GENERATOR_CLONE_DIR)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OPENAPI_GENERATOR_CLONE_DIR)"


dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "OPENAPI_GENERATOR_DOCKER_IMAGE = $(OPENAPI_GENERATOR_DOCKER_IMAGE)"
	@echo "OPENAPI_GENERATOR_GIT_TAG = $(OPENAPI_GENERATOR_GIT_TAG)"
	@echo "OPENAPI_DIR = $(OPENAPI_DIR)"
	@echo "OPENAPI_GENERATED_DIR = $(OPENAPI_GENERATED_DIR)"
	@echo "OPENAPI_CLIENT_PROPERTIES = $(OPENAPI_CLIENT_PROPERTIES)"
	@echo "OUTPUT_DIRECTORY = $(OUTPUT_DIRECTORY)"

$(OPENAPI_GENERATED_DIR):
	mkdir -p "$@"
