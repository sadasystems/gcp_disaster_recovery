provider "google" {
  version = "~> 2.0, >= 2.5.1"
  alias   = "tokengen"
}

provider "google" {
  version      = "~> 2.0, >= 2.5.1"
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.project
  # region = "us-central1"
}

resource "google_storage_bucket" "test" {
  name     = "mta-mta-rnd-mtaapp-6155-test"
  location = "us-central1"
}
