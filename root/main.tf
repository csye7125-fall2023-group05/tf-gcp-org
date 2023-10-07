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
  depends_on   = [time_sleep.creating_services]
  source       = "../modules/network"
  project_name = var.project_name
  vpc_name     = var.vpc_name
  subnet_cidr  = var.subnet_cidr
  region       = var.region
  subnet_name  = var.subnet_name
}

resource "time_sleep" "creating_network" {
  depends_on      = [module.network]
  create_duration = "60s"
}

module "vm" {
  depends_on   = [time_sleep.creating_network]
  source       = "../modules/vm"
  vm_name      = var.vm_name
  subnet_name  = var.subnet_name
  machine_type = var.machine_type
  zone         = var.zone
  static_ip    = module.network.static_ip
}

resource "time_sleep" "creating_vm" {
  depends_on      = [module.vm]
  create_duration = "60s"
}

module "os_login" {
  depends_on = [time_sleep.creating_vm]
  source     = "../modules/os_login"
  project_id = var.project_id
}
