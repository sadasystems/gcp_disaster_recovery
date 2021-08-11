provider "google" {
  #version     = ">= 3.74.0"
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  #version     = ">= 3.74.0"
  credentials = module.conjur.conjur_secret_value
}