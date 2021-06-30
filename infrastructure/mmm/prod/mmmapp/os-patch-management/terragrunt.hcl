include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/os-patch-management"
}

dependency qa-os-patch-management {
  config_path = "${path_relative_from_include()}/../../../..//infrastructure/mmm/qa/mmmapp/os-patch-management"
}

inputs = {
  exclude = dependency.qa-os-patch-management.outputs.patch_config_apt[0].excludes
}