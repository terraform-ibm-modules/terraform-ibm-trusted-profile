// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const basicExampleDir = "examples/basic"

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: basicExampleDir,
		Prefix:       "trusted-prof-basic",
	})

	terraformVars := map[string]interface{}{
		"prefix": options.Prefix,
	}

	options.TerraformVars = terraformVars

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBasicExampleEufr2(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: basicExampleDir,
		Prefix:       "trusted-prof-eu-fr2",
		Region:       "eu-fr2",
	})

	terraformVars := map[string]interface{}{
		"prefix": options.Prefix,
		"region": "eu-fr2",
	}

	options.TerraformVars = terraformVars

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunTemplateExample(t *testing.T) {

	options := setupTemplateOptions(t, "tp-template", templateExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunTemplateUpgrade(t *testing.T) {

	options := setupTemplateOptions(t, "tp-template-upg", templateExampleDir)
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
