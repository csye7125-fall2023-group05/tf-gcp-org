# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/os_login_ssh_public_key
data "google_client_openid_userinfo" "me" {}

# Add public ssh key to IAM user
resource "google_os_login_ssh_public_key" "cache" {
  user = data.google_client_openid_userinfo.me.email
  key  = file("~/.ssh/gcp-compute.pub")
}

# Allow IAM user to use OS Login
# If you are project owner or editor, this role is configured automatically.
resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/compute.osAdminLogin"
  member  = "user:${data.google_client_openid_userinfo.me.email}"
}
