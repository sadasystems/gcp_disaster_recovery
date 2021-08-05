provider "google" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "tfe" {
  hostname = "tfe.onedev.neustar.biz"
}

provider "conjur" {
  hostname = "tfe.onedev.neustar.biz"
}
