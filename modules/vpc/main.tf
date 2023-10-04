# creating a custom VPC
resource "google_compute_network" "my_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}


# creating subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr[0]
  network       = google_compute_network.my_vpc.id
  region        = var.region
}

# Router for the network
resource "google_compute_router" "csye7125_router" {
  
  name    = "csye7125-router"
  network = google_compute_network.my_vpc.name

}


# Firewall rules 
resource "google_compute_firewall" "ssh_rule" {
  name    = "ssh-firewall"
  network = google_compute_network.my_vpc.name

 allow {
    protocol = "tcp"
    ports    = ["22"]
  }

source_ranges = ["0.0.0.0/0"]
target_tags = ["csye7125_vm"]

}


