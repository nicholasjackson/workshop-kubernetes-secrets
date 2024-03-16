resource "template" "vscode_settings" {
  source = <<-EOF
  {
      "workbench.colorTheme": "GitHub Dark",
      "editor.fontSize": 16,
      "workbench.iconTheme": "material-icon-theme",
      "terminal.integrated.fontSize": 16
  }
  EOF

  destination = "${data("vscode")}/settings.json"
}

resource "template" "vscode_jumppad" {
  source = <<-EOF
  {
  "tabs": [
    {
      "name": "Docs",
      "uri": "${variable.docs_url}",
      "type": "browser",
      "active": true
    },
    {
      "name": "Terminal",
      "location": "editor",
      "type": "terminal"
    }
  ]
  }
  EOF

  destination = "${data("vscode")}/workspace.json"
}

resource "container" "vscode" {
  network {
    id = resource.network.local.meta.id
  }

  image {
    name = "nicholasjackson/kubernetes-vault-secrets-workshop:v0.1.0"
  }

  //volume {
  //  source      = resource.copy.source_files.destination
  //  destination = "/provider"
  //}

  volume {
    source      = resource.template.vscode_jumppad.destination
    destination = "/workshop/.vscode/workspace.json"
  }

  volume {
    source      = resource.template.vscode_settings.destination
    destination = "/workshop/.vscode/settings.json"
  }

  volume {
    source      = "/var/run/docker.sock"
    destination = "/var/run/docker.sock"
  }

  volume {
    source      = resource.k8s_cluster.dev.kube_config.path
    destination = "/root/.kube/config"
  }

  volume {
    source      = "./terraform/database_secrets"
    destination = "/workshop/database_secrets"
  }

  volume {
    source      = "${jumppad()}/terraform/state/${resource.terraform.service.meta.id}/terraform.tfstate"
    destination = "/workshop/database_secrets/terraform.tfstate"
  }

  environment = {
    KUBE_CONFIG_PATH = "/root/.kube/config"
    KUBECONFIG       = "/root/.kube/config"
    DEFAULT_FOLDER   = "/workshop"
    PATH             = "/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    VAULT_ADDR       = local.vault_addr
    VAULT_TOKEN      = variable.vault_token
    LC_ALL           = "C"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 8000
  }

  health_check {
    timeout = "100s"

    //http {
    //  address       = " http : //${resource.docs.docs.fqdn}/docs/provider/introduction/what_is_terraform"
    //  success_codes = [200]
    //}

    http {
      address       = "http://localhost:8000/"
      success_codes = [200, 302, 403]
    }
  }
}
