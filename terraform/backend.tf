# Remote state in the GCS bucket that sprue-works/infrastructure provisions for
# this repository (sprue-works/infrastructure#3). The block is deliberately
# empty: bucket and prefix are non-secret and are passed at `terraform init`
# from the repository variables TF_STATE_BUCKET and TF_STATE_PREFIX, so the
# values live in one place (see .github/workflows/terraform.yml and README.md).
#
# Only a workflow job running on a push to main can authenticate to the bucket:
# the workload identity provider trusts exactly this repository's
# refs/heads/main OIDC subject. There is no local or pull-request access.
terraform {
  backend "gcs" {}
}
