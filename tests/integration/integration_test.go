package test

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformIntegration(t *testing.T) {
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

	// Single deployment for all tests
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	// Run individual test scenarios as subtests
	t.Run("S3Bucket", func(t *testing.T) {
		testS3Bucket(t, opts)
	})

	t.Run("TagsAndProviders", func(t *testing.T) {
		testEnforceTagsAndProviders(t, opts)
	})
}

func testS3Bucket(t *testing.T, opts *terraform.Options) {
	s3BucketId := terraform.Output(t, opts, "s3_bucket_id")
	assert.Equal(t, "test-bucket-tf-generated", s3BucketId)
}

func testEnforceTagsAndProviders(t *testing.T, opts *terraform.Options) {
	// Validate output
	output := terraform.Output(t, opts, "default_tags")
	assert.True(
		t,
		hasTags(
			output,
			[]string{
				"Environment",
				"Owner",
				"Project",
			},
		),
		"Default tags should be present")

	assert.Contains(t, terraform.Output(t, opts, "sdm_account_ids"), "a-")
}

func hasTags(output string, tags []string) bool {
	for _, tag := range tags {
		if !strings.Contains(output, tag) {
			return false
		}
	}
	return true
}
