# genai.tf: Secure Secret Manager and Cloud Run resources

# We still use the gcloud workaround to create the secret
resource "null_resource" "api_key_secret" {
  triggers = {
    secret_id  = "${var.project_prefix}-api-key-secure" # New name
    project_id = var.gcp_project_id
  }
  provisioner "local-exec" {
    command = "gcloud secrets create ${self.triggers.secret_id} --replication-policy=automatic --project=${self.triggers.project_id}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud secrets delete ${self.triggers.secret_id} --project=${self.triggers.project_id} --quiet"
  }
  depends_on = [
    google_project_service.enabled_apis
  ]
}

# --- SECURE CONFIGURATION: Least Privilege Secret Access ---
# This resource binds our new Service Account to the secret with only the
# permission it needs: the ability to access the secret's value.
resource "google_secret_manager_secret_iam_binding" "secret_accessor_binding" {
  project   = var.gcp_project_id
  secret_id = null_resource.api_key_secret.triggers.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    # This links the policy to the service account we created in iam.tf
    "serviceAccount:${google_service_account.agent_app_sa.email}",
  ]
}

# --- SECURE CONFIGURATION: Dedicated Application Identity ---
# Create the Cloud Run service.
resource "google_cloud_run_v2_service" "agent_app" {
  project  = var.gcp_project_id
  name     = "${var.project_prefix}-agent-app-secure" # New name
  location = var.gcp_region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    # THE FIX: We are now assigning our dedicated, non-default service account.
    # The application now has a secure identity and can access other GCP
    # services based on the IAM permissions we grant this account.
    service_account = google_service_account.agent_app_sa.email
  }
  depends_on = [
    google_project_service.enabled_apis
  ]
}