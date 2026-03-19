# main.tf: Provider configuration and required APIs

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      # FINAL FIX: We are locking the provider to a specific stable version.
      version = "5.40.0"
    }
  }
}

provider "google" {
  # This will use the credentials from your gcloud CLI setup.
  # Make sure you have run 'gcloud auth application-default login'
  project = var.gcp_project_id
  region  = var.gcp_region
}

# It's a best practice to enable the necessary APIs for the project via code.
# This ensures the deployment is repeatable without manual pre-configuration.
resource "google_project_service" "enabled_apis" {
  project = var.gcp_project_id
  # Disabling deletion ensures that 'terraform destroy' doesn't disable APIs
  # that might be used by other services in the project.
  disable_on_destroy = false

  # We enable a list of services needed for our application
  for_each = toset([
    "compute.googleapis.com",             # For VPC, Firewall Rules, and VMs
    "run.googleapis.com",                 # For Cloud Run
    "secretmanager.googleapis.com",       # For Secret Manager
    "storage-component.googleapis.com",   # For Cloud Storage
    "aiplatform.googleapis.com",          # For Vertex AI (our GenAI service)
    "serviceusage.googleapis.com",        # Needed to manage other APIs
    "iam.googleapis.com"                  # For Identity and Access Management
  ])

  service = each.key
}