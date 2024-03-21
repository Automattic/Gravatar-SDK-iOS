.PHONY: all clean run

PLATFORM = iOS Simulator
OS = 17.2
DEVICE = iPhone SE (3rd generation)

SWIFTFORMAT_CACHE = ~/Library/Caches/com.charcoaldesign.swiftformat

dev:
	xed .

dev-demo:
	xed Demo/

test:
	xcodebuild test \
		-scheme Gravatar-Package \
		-destination 'platform=$(PLATFORM),OS=$(OS),name=$(DEVICE)'

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