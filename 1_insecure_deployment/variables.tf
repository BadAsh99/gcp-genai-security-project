# variables.tf: Input variables for the GCP deployment

variable "gcp_project_id" {
  description = "The GCP Project ID to deploy resources into."
  type        = string
  # --- IMPORTANT: Replace this with your actual GCP Project ID ---
  default     = "gcp-palo-alto-infra-1d3dfb"
}

variable "gcp_region" {
  description = "The GCP region for all resources."
  type        = string
  default     = "us-central1"
}

variable "project_prefix" {
  description = "A unique prefix for naming resources."
  type        = string
  default     = "finsecure-genai"
}

variable "vm_machine_type" {
  description = "The machine type for the web server VM."
  type        = string
  default     = "e2-small"
}

variable "vm_image" {
  description = "The OS image for the web server VM."
  type        = string
  default     = "debian-cloud/debian-11"
}