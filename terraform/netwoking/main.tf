data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false

  enable_dns_hostnames    = true
  map_public_ip_on_launch = true
}

module "nat" {
  source = "int128/nat-instance/aws"
  version = "2.1.0"


  # loop over the two AZs and create a NAT instance for each
  count = length(module.vpc.public_subnets)

  name                        = "${var.project_name}-nat-az-${count.index + 1}"
  vpc_id                      = module.vpc.vpc_id

  public_subnet               = module.vpc.public_subnets[count.index]
  private_subnets_cidr_blocks = [module.vpc.private_subnets_cidr_blocks[count.index]]
  private_route_table_ids     = [module.vpc.private_route_table_ids[count.index]]
}

resource "aws_eip" "nat" {
  count = length(module.nat)
  network_interface = module.nat[count.index].eni_id
  tags = {
    "Name" = "${var.project_name}-nat-instance-${count.index + 1}"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "public_ssh" {
  name   = "${var.project_name}-public-ssh"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_server1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "secureship-keypair"

  vpc_security_group_ids = [aws_security_group.public_ssh.id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name = "${var.project_name}-${var.public_server1}"
  }
}

resource "aws_instance" "public_server2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "secureship-keypair"

  vpc_security_group_ids = [aws_security_group.public_ssh.id]
  subnet_id              = module.vpc.public_subnets[1]

  tags = {
    Name = "${var.project_name}-${var.public_server2}"
  }
}

resource "aws_security_group" "private_servers" {
  name   = "${var.project_name}-private-servers"
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "SSH from public servers"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private_server1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.private_servers.id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name = "${var.project_name}-${var.private_server1}"
  }
}

resource "aws_instance" "private_server2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.private_servers.id]
  subnet_id              = module.vpc.private_subnets[1]

  tags = {
    Name = "${var.project_name}-${var.private_server2}"
  }
}
