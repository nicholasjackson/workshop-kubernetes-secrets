terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  }
}

provider "kubernetes" {
// configured using environment variables KUBE_CONFIG_PATH
//  config_path = "~/.kube/config"
}

variable "minecraft_image" {
  default = "insecure.container.local.jmpd.in:5003/minecraft:v0.2.0"
}

variable "postgres_addr" {
  default = "10.100.0.60:5432"
}