
export COMPOSE_IGNORE_ORPHANS ?= true

export RUBY_VERSION ?= 2.7.8
export BUNDLE_GEMFILE ?= Gemfile
export BUNDLER_VERSION ?= 1.17.3
ifneq ($(filter 3%,$(RUBY_VERSION)),)
export BUNDLE_GEMFILE = Gemfile.ruby3
export BUNDLER_VERSION = 2.7
else
ifneq ($(filter 2%,$(RUBY_VERSION)),)
ifneq ($(filter 2.3%,$(RUBY_VERSION)),)
export BUNDLE_GEMFILE = Gemfile.ruby23
endif
endif
endif

export COMPOSE_PROJECT_NAME = aptible-cli-$(shell echo $(RUBY_VERSION) | tr '.' '_')

$(info RUBY_VERSION = $(RUBY_VERSION))
$(info BUNDLE_GEMFILE = $(BUNDLE_GEMFILE))
$(info BUNDLER_VERSION = $(BUNDLER_VERSION))
$(info COMPOSE_PROJECT_NAME = $(COMPOSE_PROJECT_NAME))

empty:

build:
	docker compose build --pull

bash: build
	$(MAKE) run CMD=bash

CMD ?= bash
run:
	docker compose run cli $(CMD)

test: build
	$(MAKE) test-direct ARGS="$(ARGS)"

test-direct:
	docker compose run cli bundle exec rake $(ARGS)

down:
	docker compose down --remove-orphans $(ARGS)

.PHONY: build bash test
