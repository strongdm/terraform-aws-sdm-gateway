package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformBasic(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../", // Path to your Terraform code
		Vars: map[string]interface{}{
			"aws_region": os.Getenv("TF_VAR_aws_region"),
			"subnet_id":  os.Getenv("TF_VAR_subnet_id"),
			"vpc_id":     os.Getenv("TF_VAR_vpc_id"),
			"name":       os.Getenv("TF_VAR_name"),
		},
		EnvVars: map[string]string{
			"TF_VAR_tags": os.Getenv("TF_VAR_tags"),
		},
	}

	// Cleanup at the end
	defer terraform.Destroy(t, opts)

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
}
