# Build the development image
resource "build" "minecraft_dev" {
  container {
    dockerfile = "Dockerfile"
    context    = "./minecraft/DockerDev"
  }
}

# Copy the build context to a temporary directory
resource "copy" "minecraft_build" {
  source      = "./minecraft/DockerProd"
  destination = "${data("build")}"
}

# Copy the world and mods to the build context
resource "copy" "minecraft_world" {
  source      = "./minecraft/world"
  destination = "${resource.copy.minecraft_build.destination}/world"
}


resource "copy" "minecraft_mods" {
  source      = "./minecraft/mods"
  destination = "${resource.copy.minecraft_build.destination}/mods"
}

resource "copy" "minecraft_config" {
  source      = "./minecraft/config"
  destination = "${resource.copy.minecraft_build.destination}/config"
}

# Build the production image and push to the insecure registry
resource "build" "minecraft_prod" {
  container {
    dockerfile = "Dockerfile"
    context    = data("build")
  }

  registry {
    name = "${resource.container.insecure.container_name}:5003/minecraft:v0.2.0"
  }
}

resource "template" "db_username" {
  source      = variable.postgres_user
  destination = "${data("secrets")}/username"
}

resource "template" "db_password" {
  source      = variable.postgres_password
  destination = "${data("secrets")}/password"
}

resource "container" "minecraft" {
  image {
    name = resource.build.minecraft_dev.image
  }

  network {
    id = resource.network.local.meta.id
  }

  # Minecraft port
  port {
    host  = 25566
    local = 25565
  }

  # Microservice port
  port {
    host  = 8082
    local = 8082
  }

  environment = {
    GAME_MODE                 = "creative"
    WHITELIST_ENABLED         = "false"
    ONLINE_MODE               = "false"
    RCON_ENABLED              = "true"
    RCON_PASSWORD             = "password"
    SPAWN_ANIMALS             = "true"
    SPAWN_NPCS                = "true"
    VAULT_ADDR                = "http://vault.container.local.jmpd.in:8200"
    VAULT_TOKEN               = variable.vault_token
    MICROSERVICES_db_host     = "postgres.container.local.jmpd.in:5432"
    MICROSERVICES_db_username = variable.postgres_user
    MICROSERVICES_db_password = variable.postgres_password
    MICROSERVICES_db_database = variable.postgres_database
    SRE_BOT_START             = "-870,93,31"
    SRE_BOT_END               = "-866,90,36"
  }

  # Mount the secrets that contain the db connection info
  volume {
    source      = data("secrets")
    destination = "/etc/db_secrets"
  }

  # Mount the local world and config files 
  volume {
    source      = "./minecraft/world"
    destination = "/minecraft/world"
  }

  volume {
    source      = "./minecraft/config"
    destination = "/minecraft/config"
  }

  volume {
    source      = "./minecraft/mods"
    destination = "/minecraft/mods"
  }

  volume {
    source      = "./minecraft/config/ops.json"
    destination = "/minecraft/config/ops.json"
  }
}