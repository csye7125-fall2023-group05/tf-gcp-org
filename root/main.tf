module "csye7125_project" {

  source             = "../modules/project"
  project_id         = var.project_id
  project_name       = var.project_name
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  region             = var.region

}

module "csye7125_services" {

  source     = "../modules/services"
  project_id = var.project_id
  api_names  = var.api_names

}

module "csye7125_vpc" {

  source      = "../modules/vpc"
  vpc_name    = var.vpc_name
  subnet_cidr = var.subnet_cidr
  region      = var.region
  subnet_name = var.subnet_name

}

module "csye7125_vm" {
  source       = "../modules/vm"
  vm_name      = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  subnetwork   = module.csye7125_vpc.public_subnet_name

}