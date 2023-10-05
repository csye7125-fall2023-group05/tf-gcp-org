# enabling the apis that we need
resource "google_project_service" "my_project_apis" {
  for_each           = toset(var.api_names)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
  timeouts {
    create = "30m"
    update = "40m"
  }
}
