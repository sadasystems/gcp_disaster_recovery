provider "google" {
  version     = ">= 3.78.0"
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  version     = ">= 3.78.0"
  credentials = module.conjur.conjur_secret_value
}