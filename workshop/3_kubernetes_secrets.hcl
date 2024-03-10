resource "chapter" "kubernetes_secrets" {
  title = "Managing Database Secrets with Vault"

  page "introduction" {
    content = template_file("docs/kubernetes_secrets/1_kubernetes_secrets.mdx", {
    })
  }

  page "defining_secrets" {
    content = template_file("docs/kubernetes_secrets/2_defining_secrets.mdx", {
    })
  }
}