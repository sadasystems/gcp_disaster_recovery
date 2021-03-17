provider "google" {
  version = "~> 2.0, >= 2.5.1"
  alias   = "tokengen"
}

provider "google" {
  version      = "~> 2.0, >= 2.5.1"
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.project
}

# Create a Image

# VM to Instance template with source image
# input source image, network
resource "google_compute_instance_template" "default" {
  name = var.instance_template_name

  region = var.location

  # shoud be multiple disks
  disk {
    source_image = "projects/${var.project}/global/images/${var.image_names[0]}"
    auto_delete = false
    boot = true
  }

  machine_type = var.machine_type

  network_interface {
    subnetwork_project = var.subnetwork_project
    subnetwork = var.subnetwork
  }
}
