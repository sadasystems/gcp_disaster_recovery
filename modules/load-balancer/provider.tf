provider "google" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "conjur" {
  source = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"
}
/*
provider "tfe" {
  hostname = "tfe.onedev.neustar.biz"
  version = "0.13.5"
}*/
