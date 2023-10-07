resource "google_compute_instance" "csye7125_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  # tags = ["csye7125", "vm", "dev"]

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
    }
  }
  metadata = {
    os   = "debian-11"
    type = "compute-instance"
  }
}
