lint:
	tfsec .
	tflint

validate:
	terraform validate

plan: validate
	terraform plan

fmt:
	terraform fmt

unit-test:
	terraform test -test-directory=./tests/unit/aws
	terraform test -test-directory=./tests/unit/sdm

integration-test:
	go test -v ./tests/integration -timeout 30m


test: unit-test	integration-test

bootstrap:
	brew install tfsec tflint terraform

.PHONY: fmt lint validate plan test bootstrap all-static
all-static: fmt lint validate