variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu Server 22.04 LTS"
  # This AMI is for eu-central-1 region
  default = "ami-0084a47cc718c111a"
}

variable "key_name" {
  description = "The name of your EC2 Key Pair"
  default     = "valens-key" # Change this to your key pair name
}

# variable "private_key_path" {
#   description = "Local path to your private key file"
#   default     = "/home/valens/.ssh/valens-key.pub" # Change this to your local path
# }
