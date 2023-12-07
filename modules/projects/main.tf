resource "google_project" "gke_project" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = "folders/${var.gke_folder_id}"
  billing_account = var.billing_account_id
  # auto_create_network = false
}

resource "google_organization_policy" "default_network_policy" {
  org_id     = var.org_id
  constraint = "compute.skipDefaultNetworkCreation"
  boolean_policy {
    enforced = true
  }
}


