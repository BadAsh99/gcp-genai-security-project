# storage.tf: Cloud Storage bucket with a public access vulnerability

# Create the Cloud Storage bucket
resource "google_storage_bucket" "storage" {
  project      = var.gcp_project_id
  name         = "${var.project_prefix}-storage-bucket-secure" # Changed name for clarity
  location     = var.gcp_region
  force_destroy = true 

  # This setting enforces that public access is blocked.
  public_access_prevention = "enforced"
}


# --- SECURE CONFIGURATION: Public Access Removed ---
#
# The entire 'google_storage_bucket_iam_binding' resource that granted
# 'allUsers' the 'roles/storage.objectViewer' role has been DELETED.
# The bucket is now private by default.
#