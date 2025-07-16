package test

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TODO: Needs a refactoring, complex function.
func TestTerraformIntegration(t *testing.T) {
	// Step 1: Deploy prerequisites (security group)
	prereqOpts := &terraform.Options{
		TerraformDir: "./prerequisites",
		Vars: map[string]interface{}{
			"aws_region":      os.Getenv("TF_VAR_aws_region"),
			"vpc_id":          os.Getenv("TF_VAR_vpc_id"),
			"SDM_ADMIN_TOKEN": os.Getenv("TF_VAR_SDM_ADMIN_TOKEN"),
		},
		EnvVars: map[string]string{
			"TF_VAR_tags": os.Getenv("TF_VAR_tags"),
		},
	}

	// Deploy prerequisites first
	defer terraform.Destroy(t, prereqOpts)
	terraform.InitAndApply(t, prereqOpts)

	// Get security group ID from prerequisites
	securityGroupID := terraform.Output(t, prereqOpts, "security_group_id")

	// Get secret name from prerequisites
	secretName := terraform.Output(t, prereqOpts, "secret_name")

	// Step 2: Deploy main module with prerequisites
	opts := &terraform.Options{
		TerraformDir: "../../", // Path to your Terraform code
		Vars: map[string]interface{}{
			"aws_region":                  os.Getenv("TF_VAR_aws_region"),
			"aws_subnet_id":               os.Getenv("TF_VAR_subnet_id"),
			"aws_vpc_id":                  os.Getenv("TF_VAR_vpc_id"),
			"aws_security_group_id":       securityGroupID,
			"sdm_admin_token_secret_name": secretName,
			"sdm_admin_token_secret_key":  "admin_token",
			"sdm_gateway_instance_name":   "sdm-gw-integration-test",
			"aws_iam_instance_profile":    terraform.Output(t, prereqOpts, "iam_instance_profile_name"),
		},
		EnvVars: map[string]string{
			"TF_VAR_tags": os.Getenv("TF_VAR_tags"),
		},
	}

	// Deploy main module
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("TagsAndProviders", func(t *testing.T) {
		testEnforceTags(t, opts)
	})

	t.Run("GatewayConnection", func(t *testing.T) {
		testGatewayConnection(t, opts)
	})

	t.Run("SDMGatewayIsOnline", func(t *testing.T) {
		testSDMGatewayIsOnline(t, opts)
	})

	t.Run("IAMPermissions", func(t *testing.T) {
		testIAMPermissions(t, prereqOpts)
	})
}

// TODO: refactor assertions! Ugly!
func testSDMGatewayIsOnline(t *testing.T, opts *terraform.Options) {
	gatewayIP := terraform.Output(t, opts, "ec2_instance_public_dns")

	maxRetries := 12
	retryInterval := 10 * time.Second

	var lastErr error
	var output []byte

	for i := 0; i < maxRetries; i++ {
		cmd := exec.Command("sdm", "admin", "nodes", "list", "--filter", fmt.Sprintf("listen_addr:%s:5000", gatewayIP))
		output, lastErr = cmd.CombinedOutput()

		if lastErr == nil && strings.Contains(string(output), "online") {
			// Success - gateway is online
			return
		}

		if i < maxRetries-1 {
			t.Logf("Attempt %d/%d: Gateway %s not online yet, retrying in %v...", i+1, maxRetries, retryInterval, gatewayIP)
			time.Sleep(retryInterval)
		}
	}

	// All retries failed
	if lastErr != nil {
		assert.NoError(t, lastErr, "Failed to execute SDM CLI command after %d retries", maxRetries)
	} else {
		assert.Contains(t, string(output), "online", "Gateway should be online after %d retries (2 minutes)", maxRetries)
	}
}

func testGatewayConnection(t *testing.T, opts *terraform.Options) {
	gatewayIP := terraform.Output(t, opts, "ec2_instance_public_ip")
	address := gatewayIP + ":5000"
	timeout := 1 * time.Minute
	var err error
	for i := 0; i < 10; i++ {
		conn, err := net.DialTimeout("tcp", address, timeout)
		if err == nil {
			conn.Close()
			break
		}
		time.Sleep(10 * time.Second)
	}

	assert.NoError(t, err, "Should be able to connect to gateway on port 5000")

}

func testEnforceTags(t *testing.T, opts *terraform.Options) {
	// Validate output
	output := terraform.Output(t, opts, "default_tags")
	assert.True(
		t,
		hasTags(
			output,
			[]string{
				"ManagedBy",
				"Application",
			},
		),
		"Default tags should be present")
}

func hasTags(output string, tags []string) bool {
	for _, tag := range tags {
		if !strings.Contains(output, tag) {
			return false
		}
	}
	return true
}

func testIAMPermissions(t *testing.T, prereqOpts *terraform.Options) {
	// Get IAM role name from prerequisites
	roleName := terraform.Output(t, prereqOpts, "iam_role_name")

	// Use AWS CLI to check if role can access the secret (simulate the permission)
	secretName := terraform.Output(t, prereqOpts, "secret_name")
	region := os.Getenv("TF_VAR_aws_region")

	// Test that IAM role policy exists and allows secretsmanager:GetSecretValue
	cmd := exec.Command("aws", "iam", "list-role-policies", "--role-name", roleName, "--region", region)
	output, err := cmd.CombinedOutput()

	assert.NoError(t, err, "Should be able to list IAM role policies")
	assert.Contains(t, string(output), "allow-get-secret", "IAM role should have the secrets manager policy attached")

	// Test that the secret exists and is accessible
	cmd = exec.Command("aws", "secretsmanager", "describe-secret", "--secret-id", secretName, "--region", region)
	output, err = cmd.CombinedOutput()

	assert.NoError(t, err, "Secret should exist and be accessible")
	assert.Contains(t, string(output), secretName, "Secret description should contain the secret name")
}
