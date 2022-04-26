resource "google_service_account" "service-account" {
  account_id   = "account_id"
  display_name = "display_name"
}

resource "google_container_cluster" "primary" {
  name               = "gke-neo4j-dev"
  location           = "us-central1-a"
  initial_node_count = 3
  node_config {
    machine_type = "e2-standard-2"
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      foo = "neo4j-core"
    }
    tags = ["neo4j", "core"]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_compute_disk" "core-disk-1" {
  name  = "core-disk-1"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  labels = {
    environment = "neo4j-k8s"
  }
  size = 60
}

resource "google_compute_disk" "core-disk-2" {
  name  = "core-disk-2"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  labels = {
    environment = "neo4j-k8s"
  }
  size = 60
}

resource "google_compute_disk" "core-disk-3" {
  name  = "core-disk-3"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  labels = {
    environment = "neo4j-k8s"
  }
  size = 60
}
