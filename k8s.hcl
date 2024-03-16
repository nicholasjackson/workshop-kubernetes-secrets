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

resource "terraform" "service" {
  depends_on = [
    "resource.k8s_cluster.dev",
    "resource.terraform.vault_controller"
  ]

  network {
    id = resource.network.local.meta.id
  }

  environment = {
    KUBE_CONFIG_PATH = "/root/.kube/config"
  }

  source            = "./terraform/database_secrets"
  working_directory = "/"
  version           = "1.6.2"

  variables = {
    postgres_addr   = "${resource.container.postgres.network.0.assigned_address}:5432"
    minecraft_image = "docker.io/nicholasjackson/minecraft-prod:0.1.1"
  }

  volume {
    source      = resource.k8s_cluster.dev.kube_config.path
    destination = "/root/.kube/config"
  }
}

resource "ingress" "microservice_http" {
  port = 8081

  target {
    resource = resource.k8s_cluster.dev
    port     = 8082

    config = {
      service   = "service"
      namespace = "default"
    }
  }
}

resource "ingress" "minecraft" {
  port = 25565

  target {
    resource = resource.k8s_cluster.dev
    port     = 25565

    config = {
      service   = "minecraft"
      namespace = "default"
    }
  }
}