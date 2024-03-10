terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.25.0"
    }
  }
}

provider "vault" {
  address = "http://vault.container.local.jmpd.in:8200"
  token   = "root"
}

resource "vault_database_secrets_mount" "minecraft" {
  path = "database/minecraft"

  postgresql {
    name              = "minecraft"
    username          = "postgres"
    password          = "password"
    connection_url    = "postgresql://{{username}}:{{password}}@postgres.container.local.jmpd.in:5432/minecraft"
    verify_connection = true
    allowed_roles = [
      "reader",
      "writer",
      "importer"
    ]
  }
}

resource "vault_database_secret_backend_role" "importer" {
  name    = "importer"
  backend = vault_database_secrets_mount.minecraft.path
  db_name = vault_database_secrets_mount.minecraft.postgresql[0].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT postgres TO \"{{name}}\";"
  ]

  default_ttl = "100"
  max_ttl     = "100"
}

resource "vault_database_secret_backend_role" "reader" {
  name    = "reader"
  backend = vault_database_secrets_mount.minecraft.path
  db_name = vault_database_secrets_mount.minecraft.postgresql[0].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON blocks TO \"{{name}}\";",
  ]

  default_ttl = "86400"
  max_ttl     = "86400"
}

resource "vault_database_secret_backend_role" "writer" {
  name    = "writer"
  backend = vault_database_secrets_mount.minecraft.path
  db_name = vault_database_secrets_mount.minecraft.postgresql[0].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON blocks TO \"{{name}}\";",
    "GRANT INSERT ON blocks TO \"{{name}}\";",
    "GRANT UPDATE ON blocks TO \"{{name}}\";",
    "GRANT DELETE ON blocks TO \"{{name}}\";",
  ]
  
  default_ttl = "86400"
  max_ttl     = "86400"
}