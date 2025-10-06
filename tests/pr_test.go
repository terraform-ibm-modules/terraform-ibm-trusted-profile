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

// TestForEachDependencyValidation validates that the module can handle dynamic account IDs
// without encountering "known only after apply" for_each dependency errors
func TestForEachDependencyValidation(t *testing.T) {
	t.Parallel()

	const dynamicAssignmentDir = "../examples/dynamic-assignment"

	terraformOptions := &terraform.Options{
		TerraformDir: dynamicAssignmentDir,
		Vars: map[string]interface{}{
			"prefix": "tp-plan-validation",
			"region": "us-south",
		},
		NoColor: true,
	}

	// Initialize terraform
	_, initErr := terraform.InitE(t, terraformOptions)
	assert.Nil(t, initErr, "Terraform init should succeed")

	// Plan should not fail with for_each dependency errors
	_, err := terraform.PlanE(t, terraformOptions)

	if err != nil {
		errorStr := err.Error()
		// Fail the test if we find for_each dependency errors
		assert.False(t, strings.Contains(errorStr, "known only after apply") && strings.Contains(errorStr, "for_each"),
			"Found for_each dependency error - fix not working: %s", errorStr)
		assert.False(t, strings.Contains(errorStr, "Invalid for each argument"),
			"Found 'Invalid for each argument' error - fix not working: %s", errorStr)
	}
}
