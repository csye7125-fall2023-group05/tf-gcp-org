variable "region" {
  default     = "us-east1"
  type        = string
  description = "VPC region"
}

variable "dev_folder_id" {
  default     = "135331753386"
  type        = string
  description = "Dev folder ID in organization"
}

variable "folder_name" {
  default     = "test-folder"
  type        = string
  description = "GCP organization folder name"
}

variable "project_name" {
  default     = "tf-gcp-org"
  type        = string
  description = "GCP project display name"
}

# Follows regex: /^[a-z][-a-z0-9]{4,28}[a-z0-9]{1}$/gm
variable "project_id" {
  default     = "tf-gcp-org-id"
  type        = string
  description = "must be between 6 and 30 characters and can have lowercase letters, digits, or hyphens.It must start with a lowercase letter and end with a letter or number."
}

variable "org_id" {
  type        = string
  description = "The numeric ID of the organization this project belongs to"
}

variable "billing_account_id" {
  type        = string
  description = "The alphanumeric ID of the billing account this project belongs to"
}

variable "api_names" {
  type        = list(string)
  description = "list of apis to enable"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "subnet_cidr" {
  type        = list(string)
  description = "list of subnet cidr"
}

variable "subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "vm_name" {
  type        = string
  description = "VM name"
}

variable "machine_type" {
  type        = string
  description = "VM name"
}

variable "zone" {
  type        = string
  description = "Zone name"
}

variable "ssh_key_file" {
  type        = string
  description = "Public ssh key file (<filename>.pub)"
}

variable "secondary_ip_range_pod" {
  type        = string
  description = "ip range for pods"
}

variable "secondary_ip_range_service" {
  type        = string
  description = "ip range for k8s services"
}
variable "source_subnetwork_ip_ranges_to_nat" {
  type        = string
  description = ""
}
variable "nat_ip_allocate_strategy" {
  type        = string
  description = "different stratergies to use"
}
variable "account_id_kubernetes" {
  type        = string
  description = "account id for workload identity"
}
variable "initial_node_count" {
  type        = number
  description = "initial node count in the node pool"
}
variable "node_zones" {
  type        = list(string)
  description = "the zones in which we want our cluster to be deployed in"
}
