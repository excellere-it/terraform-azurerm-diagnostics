package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

func TestDefault(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/default",
		NoColor:      true,
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)
}

func TestInclude(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/include",
		NoColor:      true,
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)
}

func TestStorage(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/storage",
		NoColor:      true,
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)
}
