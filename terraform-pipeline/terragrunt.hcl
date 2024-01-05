terraform {
  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]

    required_var_files = [
      "${get_parent_terragrunt_dir()}/terraform.stg.tfvars",
      "${get_parent_terragrunt_dir()}/terraform.prod.tfvars",
      "${get_parent_terragrunt_dir()}/terraform.pipe.tfvars"
    ]

  }
}