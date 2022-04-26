provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "neo4j-core-3" {
  name       = "core-3"
  chart      = "neo4j/neo4j-cluster-core"

  values = [
    "${file("core-3.values.yaml")}"
  ]
}
