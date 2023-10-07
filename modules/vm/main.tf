resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        os   = "debian-11"
        type = "compute-instance"
      }
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    access_config {
      # ephimeral public IP config
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_access_config
      nat_ip = var.static_ip
    }
  }
  metadata = {
    # Enable os-login through metadata
    enable-oslogin : "TRUE"
  }
}
