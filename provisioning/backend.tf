/*
    Contains the configuration of the backend
*/

terraform {
  backend "gcs" {
    credentials = "../private/gcp_credentials.json"
    bucket      = "netive-infra-data"
    prefix      = "terraform/state"
  }
}