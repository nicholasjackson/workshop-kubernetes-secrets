module "workshop" {
  source = "./workshop"
  variables = {
    vault_addr         = local.vault_addr
    vault_token        = variable.vault_token
    terraform_target   = resource.container.vscode.meta.id
    postgres_addr      = "${resource.container.postgres.container_name}:5432"
    postgres_user      = variable.postgres_user
    postgres_password  = variable.postgres_password
    postgres_database  = variable.postgres_database
    service_external   = variable.service_external
    service_internal   = "http://${docker_ip()}:8081"
    minecraft_external = variable.minecraft_external
  }
}


resource "docs" "docs" {
  network {
    id = resource.network.local.meta.id
  }

  /* 
  have docs support multiple paths that get combined into docs?
  grabs all the books from the library and generates navigation
  mounts the library to a volume
  */

  // logo {
  //   url = "https://companieslogo.com/img/orig/HCP.D-be08ca6f.png"
  //   width = 32
  //   height = 32
  // }

  content = [
    module.workshop.output.book
  ]

  assets = "./workshop/images"
}
