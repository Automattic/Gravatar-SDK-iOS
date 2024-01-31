.PHONY: all clean run

dev:
	xed .

dev-demo:
	xed Demo/

test:
	xcodebuild test \
		-scheme Gravatar \
		-destination 'platform=iOS Simulator,OS=17.2,name=iPhone SE (3rd generation)'

lint-pod:
	bundle install
	bundle exec pod lib lint --verbose --fail-fast
