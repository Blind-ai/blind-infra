/*
    This file contains the providers configuration
    For any variables informations please refer to --> variables.tf
*/

provider "google" {
    credentials = var.gcp_credentials
    project     = "netive"
    region      = var.gcp_region
}

provider "aws" {
    shared_credentials_file = var.aws_credentials
    region                  = var.aws_region

}
