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
resource "google_compute_subnetwork" "private" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr[0]
  network                  = google_compute_network.vpc.name
  stack_type               = "IPV4_ONLY"
  region                   = var.region
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc]
}

#router
resource "google_compute_router" "router" {
  name    = "router"
  region  = google_compute_subnetwork.private.region
  network = google_compute_network.vpc.name
}

# NAT configuration
resource "google_compute_router_nat" "nat" {
  name                               = "nat-router"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.nat_ip_allocate_strategy
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  subnetwork {
    name                    = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.static_ip.self_link]
}

# Open the IGW
resource "google_compute_route" "egress_to_internet" {
  name             = "egress-internet-gateway"
  network          = google_compute_network.vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  description      = "Default egress route to the internet"
}

# Static public IP address
resource "google_compute_address" "static_ip" {
  name         = "static-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}
