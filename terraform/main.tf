provider "aws" {
  region = "eu-north-1"
}

module "netwoking" {
  source = "./netwoking"
}
