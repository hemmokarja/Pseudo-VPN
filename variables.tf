variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "region" {
  description = "The AWS region to deploy resources"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair"
}

variable "public_key_path" {
  description = "Path to the public key"
}

variable "allowed_ip" {
  description = "Your local machine's public IP address to allow SSH access"
}