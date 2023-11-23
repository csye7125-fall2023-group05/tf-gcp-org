module "folders" {
  source        = "../modules/folders"
  folder_name   = var.folder_name
  dev_folder_id = var.dev_folder_id
}

resource "time_sleep" "creating_folders" {
  depends_on      = [module.folders]
  create_duration = "60s"
}

module "projects" {
  depends_on         = [time_sleep.creating_folders]
  source             = "../modules/projects"
  gke_folder_id      = module.folders.gke_folder_id
  project_id         = var.project_id
  project_name       = var.project_name
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
}

resource "time_sleep" "creating_projects" {
  depends_on      = [module.projects]
  create_duration = "60s"
}

module "services" {
  depends_on = [time_sleep.creating_projects]
  source     = "../modules/services"
  project_id = var.project_id
  api_names  = var.api_names
}

resource "time_sleep" "creating_services" {
  depends_on      = [module.services]
  create_duration = "60s"
}

module "network" {
  depends_on                         = [time_sleep.creating_services]
  source                             = "../modules/network"
  project_name                       = var.project_name
  vpc_name                           = var.vpc_name
  subnet_cidr                        = var.subnet_cidr
  region                             = var.region
  subnet_name                        = var.subnet_name
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  nat_ip_allocate_strategy           = var.nat_ip_allocate_strategy
}

resource "time_sleep" "creating_network" {
  depends_on      = [module.network]
  create_duration = "60s"
}

module "bastion" {
  depends_on   = [time_sleep.creating_network]
  source       = "../modules/bastion"
  vm_name      = var.vm_name
  subnet_name  = var.subnet_name
  machine_type = var.machine_type
  zone         = var.zone
  region       = var.region
  project_id   = var.project_id
  vpc_name     = var.vpc_name
}

resource "time_sleep" "creating_bastion" {
  depends_on      = [module.bastion]
  create_duration = "10s"
}

module "os_login" {
  depends_on   = [time_sleep.creating_bastion]
  source       = "../modules/os_login"
  project_id   = var.project_id
  ssh_key_file = var.ssh_key_file
}


resource "time_sleep" "creating_os_login" {
  depends_on      = [module.os_login]
  create_duration = "10s"
}

module "k8s" {
  depends_on                 = [time_sleep.creating_os_login]
  source                     = "../modules/k8s"
  project_id                 = var.project_id
  vpc_name                   = var.vpc_name
  subnet_name                = var.subnet_name
  region                     = var.region
  account_id_kubernetes      = var.account_id_kubernetes
  initial_node_count         = var.initial_node_count
  max_node_count             = var.max_node_count
  min_node_count             = var.min_node_count
  node_zones                 = var.node_zones
  master_ipv4_cidr_block     = var.cluster_master_ip_cidr_range
  pods_ipv4_cidr_block       = var.cluster_pods_ip_cidr_range
  services_ipv4_cidr_block   = var.cluster_services_ip_cidr_range
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"
}
