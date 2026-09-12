# Remote state in the GCS bucket that sprue-works/infrastructure provisions for
# this repository (sprue-works/infrastructure#3). The block is deliberately
# empty: bucket and prefix are non-secret and are passed at `terraform init`
# from the repository variables TF_STATE_BUCKET and TF_STATE_PREFIX, so the
# values live in one place (see .github/workflows/terraform.yml and README.md).
#
# Only that workflow's apply job, running with this repository's
# refs/heads/main ref (a push to main, or a manual dispatch on main), can
# authenticate to the bucket: the workload identity provider trusts exactly
# that OIDC subject. Pull requests and other branches are rejected, and there
# is no routine local access.
terraform {
  backend "gcs" {}
}
