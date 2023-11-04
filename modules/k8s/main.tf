# Service account
resource "google_service_account" "kubernetes" {
  account_id = var.account_id_kubernetes
}

# GKE cluster
resource "google_container_cluster" "my_gke" {
  name                = "primary"
  location            = var.region
  deletion_protection = false
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = var.initial_node_count
  network                  = var.vpc_name
  subnetwork               = var.subnet_name
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  release_channel {
    channel = "REGULAR"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  dynamic "master_authorized_networks_config" {
    // TODO
    for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value
        display_name = "External Control Plane access"
      }
    }
  }

  # enable workload identity wherein all the service acc will be attached to the pods
  # so that they can access the various google services (so its pod level and not node level)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }


  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

}

# Node pool for Cluster
resource "google_container_node_pool" "gke_linux_node_pool" {
  name           = "${google_container_cluster.my_gke.name}--linux-node-pool"
  location       = google_container_cluster.my_gke.location
  node_locations = var.node_zones
  cluster        = google_container_cluster.my_gke.name
  node_count     = 1

  autoscaling {
    max_node_count = 2
    min_node_count = 1
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
      role    = "general"
      cluster = google_container_cluster.my_gke.name
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
