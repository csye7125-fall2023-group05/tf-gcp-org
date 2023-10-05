variable "region" {
  description = "VPC region"
  default     = "us-east1"
  type        = string
}

variable "dev_folder_id" {
  description = "Dev folder ID in organization"
  default     = "135331753386"
  type        = string
}

variable "folder_name" {
  description = "GCP organization folder name"
  default     = "test-folder"
  type        = string
}

variable "project_name" {
  description = "GCP project display name"
  default     = "tf-gcp-org"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  default     = "tf-gcp-org-id"
  type        = string
}

variable "org_id" {
  description = "The numeric ID of the organization this project belongs to"
  type        = string
}

variable "billing_account_id" {
  description = "The alphanumeric ID of the billing account this project belongs to"
  type        = string
}

variable "api_names" {
  description = "list of apis to enable"
  type        = list(string)
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "subnet_cidr" {
  description = "list of subnet cidr"
  type        = list(string)
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "machine_type" {
  description = "VM name"
  type        = string
}

variable "zone" {
  description = "Zone name"
  type        = string
}
