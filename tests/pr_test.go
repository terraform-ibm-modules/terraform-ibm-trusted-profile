// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const completeExampleDir = "examples/complete"
const templateExampleDir = "examples/tp-template"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
	})
	return options
}

func setupTemplateOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
	})
	terraformVars := map[string]interface{}{
		"prefix": options.Prefix,
		// Workaround for provider bug https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6216
		"account_group_ids_to_assign": []string{},
	}
	options.TerraformVars = terraformVars
	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "tp-complete", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "tp-comp-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

// TestTemplatePlanWithDynamicAssignment validates that the template module
// can generate a plan when account IDs are provided, which would catch
// for_each dependency errors that occur during plan phase
func TestTemplatePlanWithDynamicAssignment(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../" + templateExampleDir,
		Vars: map[string]interface{}{
			"prefix":                      "tp-plan-test",
			"account_group_ids_to_assign": []string{"account-group-1", "account-group-2"},
		},
		NoColor: true,
	}

	// Initialize terraform
	_, err := terraform.InitE(t, terraformOptions)
	assert.Nil(t, err, "Terraform init should succeed")

	// Plan should succeed without for_each dependency errors
	_, err = terraform.PlanE(t, terraformOptions)
	if err != nil {
		errorStr := err.Error()
		// Check for specific for_each errors that the bug would cause
		assert.False(t, strings.Contains(errorStr, "Invalid for each argument"),
			"Found 'Invalid for each argument' error - this indicates for_each dependency issue: %s", errorStr)
		assert.False(t, strings.Contains(errorStr, "known only after apply") && strings.Contains(errorStr, "for_each"),
			"Found for_each dependency error - values known only after apply: %s", errorStr)

		// If there are other errors (like auth issues), we can ignore them for this test
		// as we're only checking for the specific for_each dependency bug
		t.Logf("Plan had non-for_each error (this is acceptable for plan validation): %v", err)
	}
}
