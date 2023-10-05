output "folder_name" {
  value = google_folder.gke.name
}

output "gke_folder_id" {
  value = google_folder.gke.folder_id
}
