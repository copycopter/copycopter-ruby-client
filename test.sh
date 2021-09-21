#!/bin/sh

BUNDLE_GEMFILE=gemfiles/5.2.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/5.2.gemfile bundle exec rspec spec
BUNDLE_GEMFILE=gemfiles/6.0.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/6.0.gemfile bundle exec rspec spec
BUNDLE_GEMFILE=gemfiles/6.1.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/6.1.gemfile bundle exec rspec spec
BUNDLE_GEMFILE=gemfiles/main.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/main.gemfile bundle exec rspec spec
