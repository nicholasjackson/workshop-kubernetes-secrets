variable "minecraft_external" {
  default = ""
}

variable "service_external" {
  default = ""
}

variable "service_internal" {
  default = ""
}

variable "vault_token" {
  default = ""
}

variable "vault_addr" {
  default = ""
}

variable "terraform_target" {
  default = ""
}

variable "postgres_addr" {
  default = ""
}

variable "postgres_user" {
  default = ""
}

variable "postgres_password" {
  default = ""
}

variable "postgres_database" {
  default = ""
}

resource "book" "vault_secrets" {
  title = "Building a Terraform Provider"

  chapters = [
    resource.chapter.introduction,
    resource.chapter.database_secrets,
    resource.chapter.kubernetes_secrets,
  ]
}

output "book" {
  value = resource.book.vault_secrets
}