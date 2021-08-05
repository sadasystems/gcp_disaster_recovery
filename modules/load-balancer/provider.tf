provider "google" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "tfe" {
  hostname = var.TFE_HOSTNAME
  token = var.TFE_TOKEN
}
