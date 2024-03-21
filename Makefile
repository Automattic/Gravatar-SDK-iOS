.PHONY: all clean run

SWIFTFORMAT_CACHE = ~/Library/Caches/com.charcoaldesign.swiftformat

dev:
	xed .

dev-demo:
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

swiftformat:
	swift package plugin \
		--allow-writing-to-package-directory \
		--allow-writing-to-directory "$(SWIFTFORMAT_CACHE)" \
		swiftformat

lint:
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