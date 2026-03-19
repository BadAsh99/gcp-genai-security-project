# storage.tf: Cloud Storage bucket with a public access vulnerability

# Create the Cloud Storage bucket
resource "google_storage_bucket" "storage" {
  project      = var.gcp_project_id
  name         = "${var.project_prefix}-storage-bucket-insecure"
  location     = var.gcp_region
  force_destroy = true # Allows you to delete the bucket even if it's not empty

  # This setting is a good first step, but it's the IAM policy below that creates the real vulnerability.
  public_access_prevention = "inherited"
}


# --- INSECURE CONFIGURATION 2: Publicly Exposed Storage ---
# This resource binds an IAM role to the bucket we just created.
resource "google_storage_bucket_iam_binding" "public_read_access" {
  bucket = google_storage_bucket.storage.name

  # VULNERABILITY: The "roles/storage.objectViewer" role allows users to view objects.
  # When combined with the special "allUsers" member, it means ANYONE on the internet
  # can view objects in this bucket if they have the direct link.
  role = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}