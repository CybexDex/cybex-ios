gems-install:
	bundle install --path vendor/bundle

docs-gen:
	bundle exec jazzy --config .jazzy.yaml

lib-lint:
	bundle exec pod lib lint

pod-release:
	bundle exec pod trunk push
