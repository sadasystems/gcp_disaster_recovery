project = var.project

service_account_impersonate = "terraform@mmm-mmm-qa-mmmapp-ac0c.iam.gserviceaccount.com"

region = "us-central1"
  zone = "us-central1-a"
  name = "test-strategy"

  # HTTPS
  private_key_path = "server.key"
  certificate_path = "server.crt"

  /*The first host_rule is the default*/
  host_path_rules = [
    {
      /*named_port or NE name*/
      port_name = "https"
      host_rule = {
        host = ["*"]
        path_matcher = "p1"
      }
      path_matcher = {
        name = "p1"

        path_rule = [{
          paths = ["/*"]
        }]
      }
    }]


