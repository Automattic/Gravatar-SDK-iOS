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
		-scheme Gravatar \
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

lint-pod:
	bundle install
	bundle exec pod lib lint --verbose --fail-fast
