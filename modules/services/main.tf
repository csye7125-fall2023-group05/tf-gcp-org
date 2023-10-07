# enabling the apis that we need
resource "google_project_service" "project_apis" {
  for_each           = toset(var.api_names)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
