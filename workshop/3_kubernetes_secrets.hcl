resource "chapter" "kubernetes_secrets" {
  title = "Managing Database Secrets with Vault"

  tasks = {
    add_service_account_secret = resource.task.add_service_account_secret
    add_cluster_role           = resource.task.add_cluster_role
    add_policy                 = resource.task.add_policy
    add_role                   = resource.task.add_role
    add_vault_auth             = resource.task.add_vault_auth
    add_dynamic_secret         = resource.task.add_dynamic_secret
  }

  page "introduction" {
    content = template_file("docs/kubernetes_secrets/1_kubernetes_secrets.mdx", {
    })
  }

  page "defining_secrets" {
    content = template_file("docs/kubernetes_secrets/2_defining_secrets.mdx", {
    })
  }

  page "testing" {
    content = template_file("docs/kubernetes_secrets/3_testing.mdx", {
      app_url = "${docker_ip()}:8081"
    })
  }
}

resource "task" "add_service_account_secret" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "sa_added" {
    description = "The service account secret for authentication has been added to the config"

    check {
      script          = file("checks/kubernetes_secrets/secret_added")
      failure_message = "The 'kubernetes_secret' resource was not added to the config"
    }
  }
}

resource "task" "add_cluster_role" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "cluster_role_added" {
    description = "The cluster role binding has been added to the configuration"

    check {
      script          = file("checks/kubernetes_secrets/cluster_role_added")
      failure_message = "The 'kubernetes_cluster_role_binding' resource was not added to the config"
    }
  }
}

resource "task" "add_policy" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "policy_added" {
    description = "The vault policy has been added to the configuration"

    check {
      script          = file("checks/kubernetes_secrets/policy_added")
      failure_message = "The 'vault_policy' resource was not added to the config"
    }
  }
}

resource "task" "add_role" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "role_added" {
    description = "The vault auth role has been added to the configuration"

    check {
      script          = file("checks/kubernetes_secrets/role_added")
      failure_message = "The 'vault_kubernetes_auth_backend_role' resource was not added to the config"
    }
  }
}

resource "task" "add_vault_auth" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "role_added" {
    description = "The VaultAuth CRD has been added to the configuration"

    check {
      script          = file("checks/kubernetes_secrets/auth_added")
      failure_message = "The 'kubernetes_manifest' resource was not added to the config"
    }
  }
}

resource "task" "add_dynamic_secret" {
  prerequisites = []

  config {
    user   = "root"
    target = variable.terraform_target
  }

  condition "role_added" {
    description = "The VaultDynamicSecret CRD has been added to the configuration"

    check {
      script          = file("checks/kubernetes_secrets/dynamic_secret_added")
      failure_message = "The 'kubernetes_manifest' resource was not added to the config"
    }
  }
}