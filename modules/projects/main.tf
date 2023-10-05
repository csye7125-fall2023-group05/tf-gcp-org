resource "google_project" "vpc_project" {
  name                = var.project_name
  project_id          = var.project_id
  folder_id           = "folders/${var.gke_folder_id}"
  billing_account     = var.billing_account_id
  auto_create_network = false
}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [google_project.vpc_project]
  create_duration = "30s"
}
