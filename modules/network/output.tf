output "static_ip" {
  value = google_compute_address.static_ip.address
}

output "network" {
  value       = google_compute_network.vpc
  description = "The VPC network"
}

output "subnet" {
  value       = google_compute_subnetwork.private
  description = "The private subnet"
}
