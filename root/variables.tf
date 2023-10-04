variable "region" {
  description = "VPC region"
  default     = "us-east1"
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
