lint:
	tfsec .
	tflint

validate:
	terraform validate

plan: validate
	terraform plan

fmt:
	terraform fmt

test:
	go test -v ./test

bootstrap:
	brew install tfsec tflint terraform

.PHONY: fmt lint validate plan test bootstrap all-static
all-static: fmt lint validate