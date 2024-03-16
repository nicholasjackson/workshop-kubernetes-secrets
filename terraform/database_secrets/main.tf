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
  default = "docker.io/nicholasjackson/minecraft-prod:0.1.1"
}

variable "postgres_addr" {
  default = "10.100.0.60:5432"
}