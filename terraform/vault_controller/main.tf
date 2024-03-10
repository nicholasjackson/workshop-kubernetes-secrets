variable "vault_addr" {
  default = "http://vault.example.com:8200"
}

variable "vault_token" {
  default = "token"
}

variable "kubernetes_addr" {
  default = ""
}

variable "kubernetes_ca" {
  description = "base64 encoded kubernetes ca certificate"
  default = ""
}

provider "helm" {
  // configured using environment variables KUBE_CONFIG_PATH
  //kubernetes {
  //  config_path = "~/.kube/config"
  //}
}

provider "vault" {
  # Configuration options
  address = var.vault_addr
  token   = var.vault_token
}

// install the helm controller and set a default backend
resource "helm_release" "vault_controller" {
  name = "vault-controller"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"

  set {
    name  = "defaultVaultConnection.enabled"
    value = "true"
  }

  set {
    name  = "defaultVaultConnection.address"
    value = var.vault_addr 
  }
}

// configure the vault auth backend for kubernetes so that the vault 
// controller can authenticate
resource "vault_auth_backend" "dev" {
  type      = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "dev" {
  backend   = vault_auth_backend.dev.path

  kubernetes_host    = var.kubernetes_addr 
  kubernetes_ca_cert = base64decode(var.kubernetes_ca)
}