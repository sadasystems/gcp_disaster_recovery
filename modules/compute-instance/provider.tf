provider "google" {
  version = "~> 3.0"
  credentials = module.conjur.conjure_secret_value
}

provider "google-beta" {
  version = "~> 3.0"
  credentials = module.conjur.conjure_secret_value
}