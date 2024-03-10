resource "chapter" "introduction" {
  title = "Introduction"

  page "introduction" {
    content = template_file("docs/introduction/intro.mdx", {
    })
  }
}