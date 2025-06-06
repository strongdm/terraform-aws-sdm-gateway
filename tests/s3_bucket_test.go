package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3Bucket(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../", // Path to your Terraform code
		Vars: map[string]interface{}{
			"aws_region": os.Getenv("TF_VAR_aws_region"),
			"subnet_id":  os.Getenv("TF_VAR_subnet_id"),
			"vpc_id":     os.Getenv("TF_VAR_vpc_id"),
		},
		EnvVars: map[string]string{
			"TF_VAR_tags": os.Getenv("TF_VAR_tags"),
		},
	}

	// Cleanup at the end
	defer terraform.Destroy(t, opts)

	// Init and apply
	terraform.InitAndApply(t, opts)

}
