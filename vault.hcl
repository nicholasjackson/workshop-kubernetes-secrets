resource "container" "vault" {
  network {
    id = resource.network.local.meta.id
  }

  image {
    name = "vault:1.13.3"
  }

  port {
    local = 8200
    host  = 8200
  }

  environment = {
    VAULT_DEV_ROOT_TOKEN_ID  = variable.vault_token
    VAULT_DEV_LISTEN_ADDRESS = variable.vault_addr
    SKIP_SETCAP              = "true"
  }
}