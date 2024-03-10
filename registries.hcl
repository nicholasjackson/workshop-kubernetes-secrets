resource "container" "insecure" {
  image {
    name = "registry:2"
  }

  network {
    id = resource.network.local.meta.id
  }

  port {
    local = 5003
    host  = 5003
  }

  environment = {
    DEBUG              = "true"
    REGISTRY_HTTP_ADDR = "0.0.0.0:5003"
  }
}
