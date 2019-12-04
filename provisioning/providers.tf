/*
    This file contains the providers configuration
    For any variables informations please refer to --> variables.tf
*/

provider "google" {
  credentials = "/tmp/gcp_credentials.json"
  project     = "netive"
  region      = var.gcp_region
}