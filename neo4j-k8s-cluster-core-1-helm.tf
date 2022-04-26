provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "neo4j-core-1" {
  name       = "core-1"
  chart      = "neo4j/neo4j-cluster-core"

  values = [
    "${file("core-1.values.yaml")}"
  ]
}
