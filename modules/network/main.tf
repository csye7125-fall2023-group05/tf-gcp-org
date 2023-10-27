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
  network                  = google_compute_network.vpc.id
  stack_type               = "IPV4_ONLY"
  region                   = var.region
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc]

  #IP range for PODS
  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = var.secondary_ip_range_pod
  }

  #IP range for SERVICES
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = var.secondary_ip_range_service
  }
}

#router
resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# NAT configuration
resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  nat_ip_allocate_option             = var.nat_ip_allocate_strategy

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.static_ip.self_link]
}

# Open the IGW
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

# Service account
resource "google_service_account" "kubernetes" {
  account_id = var.account_id_kubernetes
}

# GKE cluster
resource "google_container_cluster" "my_gke" {
  name                     = "primary"
  location                 = var.region
  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = var.initial_node_count
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.private.id
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"


  # Optional, if you want multi-zonal cluster
  # node_locations = [
  #   "us-east1-b"
  # ]
  node_locations = var.node_zones

  # addons_config {
  #   http_load_balancing {
  #     disabled = true
  #   }
  #   horizontal_pod_autoscaling {
  #     disabled = false
  #   }
  # }

  release_channel {
    channel = "REGULAR"
  }

  # master_auth {
  #   client_certificate_config {
  #     issue_client_certificate = false
  #   }
  # }

  master_authorized_networks_config {

  }
  # enable workload identity wherein all the service acc will be attached to the pods
  # so that they can access the various google services (so its pod level and not node level)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }


  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}

# Node pool for Cluster
resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.my_gke.id
  node_count = 1

  autoscaling {
    min_node_count = "1"
    max_node_count = "2"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "e2-small"
    image_type   = "COS_CONTAINERD" #containerd

    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
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

  target_tags = ["bastion"]
}


