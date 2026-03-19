# genai.tf: Secret Manager and Cloud Run resources for the GenAI app

# WORKAROUND: Using a null_resource to call the gcloud command-line tool.
resource "null_resource" "api_key_secret" {
  
  triggers = {
    secret_id  = "${var.project_prefix}-api-key"
    project_id = var.gcp_project_id
  }

  # This command runs when you call 'terraform apply'.
  provisioner "local-exec" {
    # FIX #1: Removing the '$$' escaping.
    command = "gcloud secrets create ${self.triggers.secret_id} --replication-policy=automatic --project=${self.triggers.project_id}"
  }

  # This command runs when you call 'terraform destroy'.
  provisioner "local-exec" {
    when    = destroy
    # FIX #1: Removing the '$$' escaping.
    command = "gcloud secrets delete ${self.triggers.secret_id} --project=${self.triggers.project_id} --quiet"
  }
}

# --- INSECURE CONFIGURATION 4: Insecure Application Identity ---
# Create the Cloud Run service.
resource "google_cloud_run_v2_service" "agent_app" {
  project  = var.gcp_project_id
  name     = "${var.project_prefix}-agent-app"
  location = var.gcp_region

  # VULNERABILITY: We are not specifying a dedicated 'service_account'.
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  # FIX #2: Adding an explicit dependency to prevent the race condition.
  depends_on = [
    google_project_service.enabled_apis
  ]
}