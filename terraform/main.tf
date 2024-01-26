terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.51.0"
    }
  }

  required_version = ">= 0.14"
}

provider "google" {
  project = "teste-sample-388301"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_network" "vpc" {
  name                    = "vpc-gke"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-gke"
  region        = "us-central1"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "primary" {
  name     = "gke-aula-infra"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

data "google_container_engine_versions" "gke_version" {
  location = "us-central1"
  version_prefix = "1.27."
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name

  version = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = 2

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "aula"
    }

    machine_type = "n1-standard-1"
    tags         = ["gke-node", "gke-aula-infra"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
