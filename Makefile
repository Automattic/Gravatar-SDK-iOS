.PHONY: docs

dev:
	xed .

dev-demo:
	xed Demo/

lint-pod:
	bundle install
	bundle exec pod lib lint Gravatar.podspec
