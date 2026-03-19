# iam.tf: Dedicated Identity for the Cloud Run application

resource "google_service_account" "agent_app_sa" {
  account_id   = "${var.project_prefix}-agent-sa"
  display_name = "Service Account for FinSecure GenAI App"
  project      = var.gcp_project_id
}