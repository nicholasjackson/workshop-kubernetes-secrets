resource "container" "postgres" {
  network {
    id = resource.network.local.meta.id
  }

  image {
    name = "postgres:15.4"
  }

  port {
    local = 5432
    host  = 5432
  }

  environment = {
    POSTGRES_PASSWORD = variable.postgres_password
    POSTGRES_DB       = variable.postgres_database
  }

  volume {
    source      = "./sql/setup.sql"
    destination = "/docker-entrypoint-initdb.d/setup.sql"
  }
}