##################################################################################
# Fix the terraform version to be used and AWS provider version
##################################################################################

terraform {
  required_version = "~> 0.12.0"
}

##################################################################################
# Deploy the Cluster in Default VPC
##################################################################################

resource "google_container_cluster" "primary" {
  name               = "blind-cluster"
  location           = "us-central1-a"
  initial_node_count = 2

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      foo = "bar"
    }

    tags = ["foo", "bar"]
  }
}


##################################################################################
# Create 2 static IP
##################################################################################

resource "google_compute_address" "ip_address_showcase_front" {
  name = "blind-showcase-frontend"
}

resource "google_compute_address" "ip_address_platform_front" {
  name = "blind-platform-frontend"
}
