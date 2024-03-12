resource "kubernetes_service_account" "minecraft" {
  metadata {
    name = "minecraft"
  }
}

resource "kubernetes_secret" "minecraft-db" {
  metadata {
    name = "minecraft-db"
  }

  data = {
    username = "postgres"
    password = "password"
  }
}

resource "kubernetes_deployment" "minecraft" {
  metadata {
    name = "minecraft"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "minecraft"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "minecraft"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.minecraft.metadata.0.name

        container {
          image = var.minecraft_image
          name  = "minecraft"

          resources {
            limits = {
              cpu    = "1"
              memory = "4096Mi"
            }
            requests = {
              cpu    = "1"
              memory = "4096Mi"
            }
          }

          env {
            name  = "GAME_MODE"
            value = "creative"
          }
          env {
            name  = "WHITELIST_ENABLED"
            value = "false"
          }
          env {
            name  = "ONLINE_MODE"
            value = "false"
          }

          env {
            name  = "RCON_ENABLED"
            value = "true"
          }
          env {
            name  = "RCON_PASSWORD"
            value = "password"
          }
          env {
            name  = "SPAWN_ANIMALS"
            value = "true"
          }
          env {
            name  = "SPAWN_NPCS"
            value = "true"
          }
          env {
            name  = "MICROSERVICES_db_host"
            value = var.postgres_addr
          }
          env {
            name  = "MICROSERVICES_db_database"
            value = "minecraft"
          }
          env {
            name  = "SRE_BOT_START"
            value = "-870,93,31"
          }
          env {
            name  = "SRE_BOT_END"
            value = "-866,90,36"
          }
          
          volume_mount {
            name       = "db-secrets"
            mount_path = "/etc/db_secrets"
            read_only  = true
          }
        }

        volume {
          name = "db-secrets"
          secret {
            secret_name = "minecraft-db"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "minecraft" {
  metadata {
    name = "minecraft"
  }

  spec {
    selector = {
      app = "minecraft"
    }

    port {
      protocol    = "TCP"
      port        = 25565
      target_port = 25565
    }
  }
}

resource "kubernetes_service" "microservice" {
  metadata {
    name = "service"
  }

  spec {
    selector = {
      app = "minecraft"
    }

    port {
      protocol    = "TCP"
      port        = 8082
      target_port = 8082
    }
  }
}