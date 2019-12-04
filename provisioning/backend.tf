/*
    Contains the configuration of the backend
*/

terraform {
  backend "gcs" {
    bucket = "netive-infra-data"
    prefix = "terraform/state"
  }
}