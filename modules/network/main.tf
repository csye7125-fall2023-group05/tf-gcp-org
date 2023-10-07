# creating a custom VPC
resource "google_compute_network" "vpc" {
  project                         = var.project_name
  name                            = var.vpc_name
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = true
}

# creating subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr[0]
  network       = google_compute_network.vpc.id
  stack_type    = "IPV4_ONLY"
  region        = var.region
  depends_on    = [google_compute_network.vpc]
}

resource "google_compute_route" "default_to_internet" {
  name             = "default-internet-gateway"
  network          = google_compute_network.vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  description      = "Default route to the internet"
}

# Static public IP address
resource "google_compute_address" "static_ip" {
  name         = "static-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

# Firewall rules
resource "google_compute_firewall" "firewall" {
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
}


