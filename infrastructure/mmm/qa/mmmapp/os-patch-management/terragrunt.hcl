include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/os-patch-management"
}

inputs = {
  exclude = ["python"]
}

