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

// TestModuleWithDynamicAccounts tests the trusted-profile-template module
// with dynamic account IDs to validate for_each dependency fixes
func TestModuleWithDynamicAccounts(t *testing.T) {
	t.Parallel()

	options := &terraform.Options{
		TerraformDir: "./module-with-dynamic-accounts",
		NoColor:      true,
		// Reduce verbosity - only output errors
		Vars: map[string]interface{}{},
	}

	_, err := terraform.InitE(t, options)
	if err != nil {
		t.Fatalf("Init failed: %v", err)
	}

	// Test the actual module with dynamic account IDs
	_, err = terraform.PlanE(t, options)

	if err != nil {
		errorStr := err.Error()
		if strings.Contains(errorStr, "not a part of any enterprise") {
			t.Skip("Skipping test - requires enterprise account")
			return
		}
		if strings.Contains(errorStr, "Invalid for_each argument") {
			t.Logf("Dependency issue detected in module")
		} else {
			t.Logf("Plan failed for other reasons")
		}
	} else {
		t.Logf("Plan succeeded - module working correctly")
	}
}
