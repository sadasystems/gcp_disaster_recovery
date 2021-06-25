provider "google" {
  alias = "tokengen"
}

provider "google" {
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.project
}
