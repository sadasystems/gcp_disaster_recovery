data "google_client_config" "default" {
  provider = google.tokengen
}

data "google_service_account_access_token" "sa" {
  provider               = google.tokengen
  target_service_account = var.service_account_impersonate
  #lifetime               = "600s"
  scopes = [ "cloud-platform" ]
}