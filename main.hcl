variable "docs_url" {
  default = "http://localhost"
}

variable "disable_local_minecraft" {
  default = true
}

variable "minecraft_external" {
  default = "localhost:25565"
}

variable "service_external" {
  default = "http://localhost:8081"
}

variable "vault_token" {
  default = "root"
}

variable "vault_addr" {
  default = "0.0.0.0:8200"
}

variable "postgres_user" {
  default = "postgres"
}

variable "postgres_password" {
  default = "password"
}

variable "postgres_database" {
  default = "minecraft"
}

resource "network" "local" {
  subnet = "10.100.0.0/16"
}

local "vault_addr" {
  value = "http://${resource.container.vault.network.0.assigned_address}:${resource.container.vault.port.0.host}"
}

output "KUBECONFIG" {
  value = resource.k8s_cluster.dev.kube_config.path
}

output "POSTGRES_ADDR" {
  value = "${resource.container.postgres.container_name}:${resource.container.postgres.port.0.host}"
}

output "POSTGRES_USER" {
  value = variable.postgres_user
}

output "POSTGRES_PASS" {
  value = variable.postgres_password
}

output "POSTGRES_DATABASE" {
  value = variable.postgres_database
}

output "VAULT_ADDR" {
  value = "http://${resource.container.vault.container_name}:${resource.container.vault.port.0.host}"
}

output "VAULT_TOKEN" {
  value = variable.vault_token
}