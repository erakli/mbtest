SHELL = /bin/bash

default: help

.PHONY: test
test: ## Run tests
	tox -e py36,py310

.PHONY: coverage
coverage: ## Test coverage report
	tox -e coverage

.PHONY: precommit-test
precommit-test:
	tox -e py36,coverage

.PHONY: lint
lint: check-format flake8 bandit safety ## Lint code

.PHONY: flake8
flake8:
	tox -e flake8

.PHONY: bandit
bandit:
	tox -e bandit

.PHONY: extra-lint
extra-lint: pylint mypy  ## Extra, optional linting.

.PHONY: pylint
pylint:
	tox -e pylint

.PHONY: mypy
mypy:
	tox -e mypy

.PHONY: safety
safety:
	tox -e safety

.PHONY: check-format
check-format:
	tox -e check-format

.PHONY: format
format: ## Format code
	tox -e format

.PHONY: piprot
piprot: ## Check for outdated dependencies
	tox -e piprot

.PHONY: mutmut
mutmut: clean ## Run mutation tests
	tox -e mutmut run
	tox -e mutmut html
	open open html/index.html

.PHONY: docs
docs:  ## Generate documentation
	tox -e docs

.PHONY: precommit
precommit: precommit-test mypy lint docs ## Pre-commit targets
	@ python -m this

.PHONY: recreate
recreate: clean jsdeps ## Recreate tox environments
	tox --recreate --notest -p
	tox --recreate --notest -e coverage,format,check-format,flake8,pylint,bandit,safety,piprot,mypy,docs -p

.PHONY: jsdeps
jsdeps:
	- rm -r node_modules/ package.json package-lock.json
	npm install mountebank@2.5 --production

.PHONY: clean
clean: ## Clean generated files
	find . -name '*.pyc' -delete
	find . -name '*.pyo' -delete
	- rm -r build/ build_docs/ dist/ *.egg-info/ .cache .coverage .pytest_cache/ .mbdb/ .mypy_cache/ *.log *.pid *.svg .mutmut-cache html/
	find . -name "__pycache__" -type d -print | xargs -t rm -r
	find . -name "test-output" -type d -print | xargs -t rm -r

.PHONY: repl
repl: ## Python REPL
	tox -e py310 -- python

.PHONY: outdated
outdated: ## List outdated dependancies
	tox -e py310 -- pip list -o

.PHONY: help
help: ## Show this help
	@ grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1,$$2}'
