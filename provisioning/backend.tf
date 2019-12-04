/*
    Contains the configuration of the backend
*/

terraform {
  backend "gcs" {
    credentials = var.gcp_credentials
    bucket      = "netive-infra-data"
    prefix      = "terraform/state"
  }
}