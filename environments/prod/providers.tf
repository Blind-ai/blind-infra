##################################################################################
# AWS Provider configuration
##################################################################################

provider "google" {
  credentials = var.gcp_credentials
  project     = "blind-ai-263012"
  region      = "us-central1"
}