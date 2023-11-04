locals {
  hostname = format("%s-bastion", var.vpc_name)
}

resource "google_compute_instance" "bastion" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        os   = "debian-11"
        type = "compute-instance"
      }
    }
  }

  tags = ["bastion"]

  metadata_startup_script = file("../modules/bastion/startup.sh")

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true
  network_interface {
    subnetwork = var.subnet_name
    # subnetwork = "${google_compute_network.vpc.name}-subnet"
    access_config {
      # ephimeral public IP config
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_access_config
      # nat_ip = var.static_ip
      network_tier = "STANDARD"
    }
  }
  metadata = {
    # Enable os-login through metadata
    enable-oslogin : "TRUE"
  }

  /* local-exec providers may run before the host has fully initialized.
  However, they are run sequentially in the order they were defined.
  This provider is used to block the subsequent providers until the instance is available. */
  #   provisioner "local-exec" {
  #     command = <<EOF
  #         READY=""
  #         for i in $(seq 1 20); do
  #           if gcloud compute ssh ${local.hostname} --project ${var.project_id} --zone ${var.region}-a --command uptime; then
  #             READY="yes"
  #             break;
  #           fi
  #           echo "Waiting for ${local.hostname} to initialize..."
  #           sleep 10;
  #         done
  #         if [[ -z $READY ]]; then
  #           echo "${local.hostname} failed to start in time."
  #           echo "Please verify that the instance starts and then re-run `terraform apply`"
  #           exit 1
  #         fi
  # EOF
  #   }
}

// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "bastion-ssh" {
  name          = format("%s-bastion-ssh", var.vpc_name)
  network       = var.vpc_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"] // TODO: Restrict further.

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion"]
}
