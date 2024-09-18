include {
  path = find_in_parent_folders()
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy", "import"]
    arguments = [
      "-compact-warnings",
      "-var-file=../environment.tfvars",
    ]
  }
}
