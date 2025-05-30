lint:
	tfsec .
	tflint

validate:
	terraform validate

plan:
	terraform plan

fmt:
	terraform fmt

test:
	go test -v ./test

.PHONY: fmt lint validate test
all-static: fmt lint validate test
