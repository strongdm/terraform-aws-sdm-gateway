package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformBasic(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../", // Path to your Terraform code
	}

	// Init and apply
	terraform.InitAndApply(t, opts)

	// Validate output
	output := terraform.Output(t, opts, "default_tags")
	assert.Contains(t, output, "Environment")
	assert.Contains(t, output, "Owner")
	assert.Contains(t, output, "Project")
	assert.Contains(t, output, "Name")
	assert.Contains(t, output, "ManagedBy")
	assert.Contains(t, output, "Application")

	// Cleanup
	defer terraform.Destroy(t, opts)
}
