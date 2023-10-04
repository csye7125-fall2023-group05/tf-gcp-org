resource "google_compute_instance" "csye7125_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["csye7125_vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = var.subnetwork
    access_config {
      // Ephemeral public IP
    }
  }

}