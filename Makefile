lint:
	tfsec .
	tflint

validate:
	terraform validate

plan:
	terraform plan

fmt:
	terraform fmt

.PHONY: fmt lint validate 
all: fmt lint validate
