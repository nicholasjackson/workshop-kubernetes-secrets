resource "kubernetes_service_account" "minecraft" {
  metadata {
    name = "minecraft"
  }
}

resource "kubernetes_secret" "minecraft-token" {
  metadata {
    name = "${kubernetes_service_account.minecraft.metadata.0.name}-token"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.minecraft.metadata.0.name
    }
  }

  type = "kubernetes.io/service-account-token"
}

//resource "kubernetes_cluster_role_binding" "minecraft" {
//  metadata {
//    name = "role-tokenreview-binding"
//  }
//  role_ref {
//    api_group = "rbac.authorization.k8s.io"
//    kind      = "ClusterRole"
//    name      = "system:auth-delegator"
//  }
//  subject {
//    kind      = "ServiceAccount"
//    name      = kubernetes_service_account.minecraft.metadata.0.name
//    namespace = "default"
//  }
//}

resource "vault_policy" "minecraft_secrets" {
  name = "minecraft-secrets"

  policy = <<EOF
  path "${vault_database_secrets_mount.minecraft.path}/creds/reader" {

    capabilities = ["read", "create", "update"]
  }
  EOF
}

resource "vault_kubernetes_auth_backend_role" "minecraft" {
  backend   = "kubernetes"
  role_name = "minecraft"

  bound_service_account_names      = [kubernetes_service_account.minecraft.metadata.0.name]
  bound_service_account_namespaces = ["default"]
  token_policies                   = [vault_policy.minecraft_secrets.name]
}

resource "kubernetes_manifest" "vaultauth_dev_auth" {
  manifest = {
    "apiVersion" = "secrets.hashicorp.com/v1beta1"
    "kind"       = "VaultAuth"
    "metadata" = {
      "name"      = "dev-auth"
      "namespace" = "default"
    }
    "spec" = {
      "allowedNamespaces" = [
        "*",
      ]
      "kubernetes" = {
        "role"                   = vault_kubernetes_auth_backend_role.minecraft.role_name
        "serviceAccount"         = kubernetes_service_account.minecraft.metadata.0.name
        "tokenExpirationSeconds" = 600
      }
      "method"             = "kubernetes"
      "mount"              = "kubernetes"
      "vaultConnectionRef" = "default"
    }
  }
}

resource "kubernetes_manifest" "vault_dynamic_secret" {
  manifest = {
    "apiVersion" = "secrets.hashicorp.com/v1beta1"
    "kind"       = "VaultDynamicSecret"
    "metadata" = {
      "name"      = "minecraft-db"
      "namespace" = "default"
    }
    "spec" = {
      "mount"     = vault_database_secrets_mount.minecraft.path
      "path"      = "creds/reader"

      "destination" = {
        "create" = true
        "name"   = "minecraft-db"
      }
      "vaultAuthRef" = "dev-auth"
    }
  }
}