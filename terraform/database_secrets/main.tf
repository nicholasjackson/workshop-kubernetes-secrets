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