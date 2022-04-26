provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "lbneo4j" {
  name       = "lb-neo4j-dev"
  chart      = "neo4j/neo4j-cluster-loadbalancer"

  set {
    name  = "neo4j.name"
    value = "gke-neo4j-dev"
  }
}
