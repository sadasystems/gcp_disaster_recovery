provider "google" {
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  credentials = module.conjur.conjur_secret_value
}