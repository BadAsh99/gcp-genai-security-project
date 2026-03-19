# compute.tf: Web Server VM that will be exposed to the internet

resource "google_compute_instance" "web_vm" {
  project      = var.gcp_project_id
  name         = "${var.project_prefix}-web-vm"
  machine_type = var.vm_machine_type
  zone         = "${var.gcp_region}-b" # Deploying to the 'b' zone in the selected region

  # This tag links the VM to our insecure firewall rule, exposing port 22.
  tags = ["web-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  # This section defines the network interface for the VM.
  network_interface {
    # Attaching to the VPC we created
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.web_subnet.id

    # This assigns an ephemeral public IP address to the VM, making it reachable from the internet.
    access_config {
    }
  }

  # This allows the OS to perform auto-updates and other management tasks.
  service_account {
    scopes = ["cloud-platform"]
  }
}