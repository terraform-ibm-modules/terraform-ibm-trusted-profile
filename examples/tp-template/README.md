# Trusted Profile Template example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=trusted-profile-tp-template-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/tree/main/examples/tp-template">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end basic example that demonstrates how to use the `trusted-profile-template` submodule. This example will create:

- A new resource group if one is not passed in.
- A new Cloud Object Storage instance.
- A trusted profile template with one COS reader policy

:warning: This example will only execute on an enterprise account
