.PHONY: all clean run

dev:
	xed .

dev-demo:
	xed Demo/

lint-pod:
	bundle install
	bundle exec pod lib lint --verbose --fail-fast
