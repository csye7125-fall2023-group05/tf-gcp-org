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

# resource "google_binary_authorization_policy" "binary_auth_policy" {
#   admission_whitelist_patterns {
#     name_pattern = "gcr.io/google_containers/*"
#   }

#   default_admission_rule {
#     evaluation_mode  = "ALWAYS_ALLOW"
#     enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
#   }
# }

