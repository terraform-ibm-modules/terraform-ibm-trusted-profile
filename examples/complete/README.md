# Complete example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=trusted-profile-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/tree/main/examples/complete">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

<!-- There is a pre-commit hook that will take the title of each example add include it in the repos main README.md  -->
<!-- Add text below should describe exactly what resources are provisioned / configured by the example  -->

An end-to-end example that will provision the following:
- A new VPC instance
- A new VSI in the VPC
- A new Trusted Profile
- A valid Access Policy for the profile
- A valid Claim Rule for the profile
- A valid Link for the profile to the VSI
- A CRN identity type scoped to the VSI CRN
