module "folders" {
  source        = "../modules/folders"
  folder_name   = var.folder_name
  org_id        = var.org_id
  dev_folder_id = var.dev_folder_id
}

module "projects" {
  source             = "../modules/projects"
  gke_folder_id      = module.folders.gke_folder_id
  project_id         = var.project_id
  project_name       = var.project_name
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  region             = var.region
}

module "services" {
  source     = "../modules/services"
  project_id = var.project_id
  api_names  = var.api_names
}

module "network" {
  source       = "../modules/network"
  project_name = var.project_name
  vpc_name     = var.vpc_name
  subnet_cidr  = var.subnet_cidr
  region       = var.region
  subnet_name  = var.subnet_name
}

module "vm" {
  source       = "../modules/vm"
  vm_name      = var.vm_name
  vpc_name     = var.vpc_name
  subnet_name  = var.subnet_name
  machine_type = var.machine_type
  region       = var.region
  zone         = var.zone
  subnetwork   = module.network.public_subnet_name
}
