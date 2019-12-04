/*
  Entry point of Netive IAC
*/


module "netive-network" {
  source = "./modules/netive-network"
}

module "netive-platform" {
  source = "./modules/netive-platform"
}

module "netive-showcase" {
  source = "./modules/netive-showcase"
}