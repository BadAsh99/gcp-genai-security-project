# network.tf: VPC, Subnets, and the insecure Firewall Rule

# Create the Virtual Private Cloud (VPC) network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_prefix}-vpc"
  auto_create_subnetworks = false # Best practice is to create subnets manually
  project                 = var.gcp_project_id
}

# Create a subnet for the web server
resource "google_compute_subnetwork" "web_subnet" {
  name          = "${var.project_prefix}-web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
  project       = var.gcp_project_id
}

# Create a subnet for the backend application (Cloud Run)
resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.project_prefix}-app-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
  project       = var.gcp_project_id
}

# --- SECURE CONFIGURATION: Restricted Network Access ---
# This firewall rule now only allows SSH from a trusted source IP range.
resource "google_compute_firewall" "allow_ssh_from_trusted_source" {
  name    = "${var.project_prefix}-allow-ssh-trusted"
  network = google_compute_network.vpc.name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # THE FIX: We now reference a variable for a specific admin IP range
  # instead of hardcoding "0.0.0.0/0".
  source_ranges = [var.admin_ip_cidr]
  target_tags   = ["web-server"]
}