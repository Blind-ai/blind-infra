# ---------------------------------------------------------------------------------------------------------------------
# Backend configuration for Blind Project
# Connect to GCP Storage
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  backend "gcs" {
    bucket  = "tf-state-blind"
    prefix  = "terraform/state"
  }
}
