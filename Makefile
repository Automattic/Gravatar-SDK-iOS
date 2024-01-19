.PHONY: docs

dev:
	xed .

dev-demo:
	xed Demo/

docs:
	swift package generate-documentation

build:
	swift build

test:
	swift test

lint-pod:
	bundle install
	bundle exec pod lib lint Gravatar.podspec
