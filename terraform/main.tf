provider "aws" {
  region = "eu-west-3"
}

module "netwoking" {
  source = "./netwoking"
}
