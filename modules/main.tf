/*
Please, add all your applications under a project here.

If you like to provision a new VM,
  select source repo 'compute-instance'

If you like to provision a new VM and enable Disaster Recovery for the VM,
  select source repo 'compute-instance-disaster-recovery'

If you like to enable Disaster Recovery,
  select source repo 'disaster-recovery'
*/
locals {
  project =  "mmm-mmm-qa-mmmapp-ac0c"
}

module "new-vm-dr" {
  source = "./compute-instance-disaster-recovery"
  project = local.project
  service_account = {
    // Please, create a new service account.
    email  = ""
    scopes = ["cloud-platform"]
  }

  region  = "us-central1"
  zone    = "us-central1-a"

  subnetwork_project = "ent-net-mta-host-fde3"
  subnetwork = "neustar-shared-nonprod-usc1-mta-qa-subnet-4bf9"
  startup_script        = ""

  vm_name = "vm-dr"
  machine_type = "e2-medium"
  igm_initial_delay_sec = 30
  network_tag = ["allow-all-gfe"]

  named_ports = [
    {
      name = "https"
      port = 443
    }
  ]

  disks = [
    {
      boot         = true
      auto_delete  = false
      disk_name    = "disk1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      source_image = "ubuntu-os-cloud/ubuntu-1804-lts" #image_family/image_name
    },    {
      boot         = false
      auto_delete  = false
      disk_name    = "disk2"
      disk_size_gb = 20
      disk_type    = "pd-ssd"
      source_image = ""
    }
  ]

  # Snapshot schedule
  # https://cloud.google.com/compute/docs/disks/scheduled-snapshots
  snapshot = {
    hours              = 1        # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1        # how long keep snapshots
  }

  # Health check for VM
  # https://cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs#example_health_check_set_up
  http_health_check_enabled = false # 'false' to use TCP protocol, 'true' to use HTTP
  health_check = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    request_path        = ""
    port                = 22
  }
}

module "test-strategy-dr" {
  source = "./disaster-recovery"
  project = local.project

  // leave it blank if you like to use the same service account of source VM.
  service_account = {
    email  = ""
    scopes = []
  }

  region = "us-central1"
  zone   = "us-central1-a"

  source_vm = "test-strategy" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  network_tag = ["allow-all-gfe"]

  /*
  // Only used for updating
  // if there is no source_vm then provision and dr,  otherwise modifying
  // modify volume
  // add volume
  // machine type change
  volumes = {
    name = ""
    size = ""
  }

  enable_dr=true
  machine_type = "n2-"
  update_restart = true
  */

  # Named ports
  named_ports = [
    {
      name = "https"
      port = 443
    }
  ]

  # Instance group manager
  igm_initial_delay_sec = "120" # booting time
  startup_script        = ""

  disk_type = "pd-ssd" # "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard"

  # Snapshot schedule
  # https://cloud.google.com/compute/docs/disks/scheduled-snapshots
  snapshot = {
    hours              = 1 # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1 # how long keep snapshots
  }

  # Health check for VM
  # https://cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs#example_health_check_set_up
  http_health_check_enabled = false # 'false' to use TCP protocol, 'true' to use HTTP
  health_check = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    request_path        = ""
    port                = 22
  }
}

module "new-vm" {
  source = "./compute-instance"  # If you like to provision
  project = local.project
  service_account = {
    // Please, create a new service account.
    email  = ""
    scopes = ["cloud-platform"]
  }

  region  = "us-central1"
  zone    = "us-central1-a"

  subnetwork_project = "ent-net-mta-host-fde3"
  subnetwork = "neustar-shared-nonprod-usc1-mta-qa-subnet-4bf9"
  startup_script        = ""

  vm_name = "vm-no-dr"
  machine_type = "e2-medium"
  allow_stopping_for_update = true

  boot_disk = {
    auto_delete = false
    device_name = "boot-disk"
    initialize_params = {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = 10
      type = "pd-ssd"
    }
  }

  disks = [
    {
      boot         = false
      auto_delete  = false
      disk_name    = "d1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      source_image = ""
    },    {
      boot         = false
      auto_delete  = false
      disk_name    = "d2"
      disk_size_gb = 20
      disk_type    = "pd-ssd"
      source_image = ""
    }
  ]

  # Snapshot schedule
  # https://cloud.google.com/compute/docs/disks/scheduled-snapshots
  snapshot = {
    hours              = 1        # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1        # how long keep snapshots
  }
}