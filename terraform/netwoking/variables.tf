variable "project_name" {
  description = "Project name"
  type        = string
  default     = "secureship"
}

variable "public_server1" {
  description = "value of the ec2 instance"
  type        = string
  default     = "public-server1"
}

variable "public_server2" {
  description = "value of the ec2 instance"
  type        = string
  default     = "public-server2"
}

variable "private_server1" {
  description = "value of the ec2 instance"
  type        = string
  default     = "private-server1"
}

variable "private_server2" {
  description = "value of the ec2 instance"
  type        = string
  default     = "private-server2"
}

variable "instance_type" {
  description = "type of the ec2 instance"
  type        = string
  default     = "t2.micro"
}
