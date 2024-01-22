.PHONY: docs

dev:
	xed .

dev-demo:
	xed Demo/

docs:
	swift package generate-documentation

lint-pod:
	bundle install
	bundle exec pod lib lint Gravatar.podspec
