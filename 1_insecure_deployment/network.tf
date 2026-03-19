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

# --- INSECURE CONFIGURATION 1: Overly Permissive Network Access ---
# This firewall rule allows SSH traffic (port 22) from ANY source IP address.
resource "google_compute_firewall" "allow_ssh_from_internet" {
  name    = "${var.project_prefix}-allow-ssh-internet"
  network = google_compute_network.vpc.name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # VULNERABILITY: 'source_ranges' is set to '0.0.0.0/0', which means "the entire internet".
  # This exposes the VM to constant brute-force attacks.
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"] # This rule will apply to any VM with this tag
}