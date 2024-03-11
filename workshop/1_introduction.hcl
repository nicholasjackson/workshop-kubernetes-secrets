resource "chapter" "introduction" {
  title = "Introduction"

  page "introduction" {
    content = template_file("docs/introduction/intro.mdx", {
      minecraft_external = variable.minecraft_external
      service_external   = variable.service_external
      service_internal   = "http://${docker_ip()}:8081"
    })
  }
}