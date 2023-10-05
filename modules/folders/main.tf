resource "google_folder" "gke" {
  parent       = "folders/${var.dev_folder_id}"
  display_name = var.folder_name
}
