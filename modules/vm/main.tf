data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  curl -LO https://dl.k8s.io/release/v1.28.3/bin/linux/amd64/kubectl
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  chmod +x kubectl
  mkdir -p ~/.local/bin
  mv ./kubectl ~/.local/bin/kubectl
  kubectl version --client

  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm version
  EOF
}

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

  tags = ["bastion"]

  metadata_startup_script = data.template_file.startup_script.rendered

  network_interface {
    subnetwork = var.subnet_name
    access_config {
      # ephimeral public IP config
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_access_config
      # nat_ip = var.static_ip
    }
  }
  metadata = {
    # Enable os-login through metadata
    enable-oslogin : "TRUE"
  }
}
