dev:
	xed .

dev-example:
	xed Example/

build:
	swift build

test:
	swift test

lint-pod:
	bundle install
	bundle exec pod lib lint Gravatar.podspec
