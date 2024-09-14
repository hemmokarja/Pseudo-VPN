resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]  # allow SSH access from your local machine only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # allow all outbound traffic (for browsing the web)
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pseudo_vpn_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [
    aws_security_group.allow_ssh.name
  ]

  tags = {
    Name = "Pseudo-VPN-EC2"
  }
}

# fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # canonical (Ubuntu) AWS account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

