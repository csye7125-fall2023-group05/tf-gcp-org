variable "region" {
  default     = "us-east1"
  type        = string
  description = "VPC region"
}

variable "dev_folder_id" {
  default     = "135331753386"
  type        = string
  description = "Dev/Prod folder ID in organization. Default is dev folder ID"
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
  description = "The compute instance machine type. Default machine has 8 vCPU and 32GiB vRAM"
  default     = "e2-standard-8"
}

variable "zone" {
  type        = string
  description = "Zone name"
}

variable "ssh_key_file" {
  type        = string
  description = "Public ssh key file (<filename>.pub)"
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
  description = "service account id for workload identity with access to GKE cluster node pools"
}
variable "initial_node_count" {
  type        = number
  description = "initial node count in the node pool"
}
variable "node_zones" {
  type        = list(string)
  description = "the zones in which we want our cluster to be deployed in"
}

variable "cluster_master_ip_cidr_range" {
  type        = string
  description = "The CIDR range to use for Kubernetes cluster master"
}

variable "cluster_pods_ip_cidr_range" {
  type        = string
  description = "The CIDR range to use for Kubernetes cluster pods"
}

variable "cluster_services_ip_cidr_range" {
  type        = string
  description = "The CIDR range to use for Kubernetes cluster services"
}

variable "max_node_count" {
  type        = number
  description = "The max node count when autoscaling the cluster"
}

variable "min_node_count" {
  type        = number
  description = "THe min node count when autoscaling the cluster"
}
