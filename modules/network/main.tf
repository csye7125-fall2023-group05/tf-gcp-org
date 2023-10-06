# creating a custom VPC
resource "google_compute_network" "vpc" {
  project                         = var.project_name
  name                            = var.vpc_name
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}

# creating subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr[0]
  network       = google_compute_network.vpc.id
  region        = var.region
  depends_on    = [google_compute_network.vpc]
}

# Router for the network
resource "google_compute_router" "csye7125_router" {
  name    = "csye7125-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Firewall rules
resource "google_compute_firewall" "ssh_rule" {
  name    = "ssh-firewall"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  # allow incoming traffic through SSH port
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  # target_tags   = ["csye7125", "vm", "dev"]
}


