.PHONY: install

install:
	bundle install --path vendor/bundle
	# carthage bootstrap --platform ios --cache-builds
	bundle exec pod install --repo-update

update:
	# carthage update --platform ios --cache-builds
	bundle exec pod install
