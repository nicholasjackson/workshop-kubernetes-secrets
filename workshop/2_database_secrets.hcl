resource "chapter" "database_secrets" {
  title = "Managing Database Secrets with Vault"

  tasks = {
    install_provider   = resource.task.install_provider
    configure_provider = resource.task.configure_provider
    add_secrets_mount  = resource.task.add_secrets_mount
    add_import_role    = resource.task.add_import_role
    add_reader_role    = resource.task.add_reader_role
    add_writer_role    = resource.task.add_writer_role
  }

  page "introduction" {
    content = template_file("docs/database_secrets/1_intro.mdx", {
      vault_addr  = variable.vault_addr
      vault_token = variable.vault_token
    })
  }

  page "configure" {
    content = template_file("docs/database_secrets/2_configure.mdx", {
      vault_addr        = variable.vault_addr
      vault_token       = variable.vault_token
      postgres_addr     = variable.postgres_addr
      postgres_user     = variable.postgres_user
      postgres_password = variable.postgres_password
      postgres_database = variable.postgres_database
    })
  }

  page "roles_1" {
    content = template_file("docs/database_secrets/3_create_roles.mdx", {
      vault_addr        = variable.vault_addr
      vault_token       = variable.vault_token
      postgres_addr     = variable.postgres_addr
      postgres_user     = variable.postgres_user
      postgres_password = variable.postgres_password
      postgres_database = variable.postgres_database
    })
  }

  page "roles_2" {
    content = template_file("docs/database_secrets/4_create_roles_2.mdx", {
      vault_addr        = variable.vault_addr
      vault_token       = variable.vault_token
      postgres_addr     = variable.postgres_addr
      postgres_user     = variable.postgres_user
      postgres_password = variable.postgres_password
      postgres_database = variable.postgres_database
    })
  }
}

resource "task" "install_provider" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "provider_added" {
    description = "The vault provider is added to the code"

    check {
      script          = file("checks/database_secrets/provider_added")
      failure_message = "The 'hashicorp/vault' provider was not added to required_providers"
    }

    //.solve {
    //.  script  = file("checks/providers/install_provider/solve")
    //.  timeout = 120
    //.}
  }

  condition "provider_installed" {
    description = "The vault provider is installed"

    check {
      script          = file("checks/database_secrets/provider_installed")
      failure_message = "the vault provider was not correctly initialized"
    }
  }

  condition "provider_initialized" {
    description = "Terraform init has been executed"

    check {
      script          = file("checks/database_secrets/provider_init")
      failure_message = "terraform init has not been executed"
    }
  }
}

resource "task" "configure_provider" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "provider_configured" {
    description = "The vault provider has been configured"

    check {
      script          = file("checks/database_secrets/provider_configured")
      failure_message = "Add the provider block to your code and configure it with the correct address and token"
    }
  }
}

resource "task" "add_secrets_mount" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "mount_added" {
    description = "The vault database secret mount has been added"

    check {
      script          = file("checks/database_secrets/mount_added")
      failure_message = "Add the `vault_database_secrets_mount` to your code"
    }
  }
}

resource "task" "add_import_role" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "role_added" {
    description = "The vault role has been added to the terraform code"

    check {
      script          = file("checks/database_secrets/import_role_added")
      failure_message = "Add the `vault_database_secrets_mount` to your code"
    }
  }

  condition "terraform_applied" {
    description = "Terraform apply has been executed"

    check {
      script          = file("checks/database_secrets/terraform_applied")
      failure_message = "Run `terraform apply` to apply the changes to the infrastructure"
    }
  }
}

resource "task" "add_reader_role" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "role_added" {
    description = "The vault role has been added to the terraform code"

    check {
      script          = file("checks/database_secrets/reader_role_added")
      failure_message = "Add the `vault_database_secret_backend_role` to your code"
    }
  }

  condition "terraform_applied" {
    description = "The TTL has been set to 24hrs"

    check {
      script          = file("checks/database_secrets/reader_role_has_ttl")
      failure_message = "Ensure the TTL is set to 24hrs or 86400"
    }
  }
}

resource "task" "add_writer_role" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "role_added" {
    description = "The vault role has been added to the terraform code"

    check {
      script          = file("checks/database_secrets/writer_role_added")
      failure_message = "Add the `vault_database_secret_backend_role` to your code"
    }
  }

  condition "terraform_applied" {
    description = "The TTL has been set to 24hrs"

    check {
      script          = file("checks/database_secrets/writer_role_has_ttl")
      failure_message = "Ensure the TTL is set to 24hrs or 86400"
    }
  }
}