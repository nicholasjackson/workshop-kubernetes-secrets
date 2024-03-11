terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.25.0"
    }
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

provider "vault" {
  address = "http://vault.container.local.jmpd.in:8200"
  token   = "root"
}

variable "minecraft_image" {
  default = "insecure.container.local.jmpd.in:5003/minecraft:v0.2.0"
}

variable "postgres_addr" {
  default = "10.5.0.60:5432"
}