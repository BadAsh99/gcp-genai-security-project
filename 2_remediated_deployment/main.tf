# main.tf: Provider configuration and required APIs

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      # We are locking the provider to a stable 5.x version.
      version = "5.40.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# This is the resource block that was missing.
resource "google_project_service" "enabled_apis" {
  project = var.gcp_project_id

  # We are telling Terraform to leave the APIs enabled
  # when we destroy the infrastructure.
  disable_on_destroy = false

  for_each = toset([
    "compute.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "storage-component.googleapis.com",
    "aiplatform.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com"
  ])

  service = each.key
}