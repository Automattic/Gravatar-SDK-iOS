.PHONY: all clean run

SWIFTFORMAT_CACHE = ~/Library/Caches/com.charcoaldesign.swiftformat

dev:
	xed .

dev-demo:
	xed Demo/

test:
	bundle exec fastlane test

build-demo:
	bundle exec fastlane build_demo scheme:Gravatar-Demo
	bundle exec fastlane build_demo scheme:Gravatar-SwiftUI-Demo

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

validate-pod:
	# For some reason this fixes a failure in `lib lint`
	# https://github.com/Automattic/buildkite-ci/issues/7
	xcrun simctl list >> /dev/null
	bundle install
	bundle exec pod lib lint \
		--include-podspecs="*.podspec" \
		--verbose --fail-fast