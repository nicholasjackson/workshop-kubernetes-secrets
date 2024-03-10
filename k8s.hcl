resource "k8s_cluster" "dev" {
  network {
    id = resource.network.local.meta.id
  }

  config {
    docker {
      no_proxy            = ["insecure.container.local.jmpd.in"]
      insecure_registries = ["insecure.container.local.jmpd.in:5003"]
    }
  }
}

resource "terraform" "vault_controller" {
  network {
    id = resource.network.local.meta.id
  }

  environment = {
    KUBE_CONFIG_PATH = "/root/.kube/config"
  }

  source            = "./terraform/vault_controller"
  working_directory = "/"
  version           = "1.6.2"

  variables = {
    vault_addr      = local.vault_addr
    vault_token     = variable.vault_token
    kubernetes_addr = "https://${resource.k8s_cluster.dev.container_name}"
    kubernetes_ca   = resource.k8s_cluster.dev.kube_config.ca
  }

  volume {
    source      = resource.k8s_cluster.dev.kube_config.path
    destination = "/root/.kube/config"
  }
}