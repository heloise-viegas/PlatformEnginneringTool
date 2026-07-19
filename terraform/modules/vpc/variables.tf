variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

# Map of AZ → CIDR, e.g. { "ap-south-1a" = "10.0.1.0/24", "ap-south-1b" = "10.0.2.0/24" }
variable "pub_subnets" {
  description = "Map of AZ to CIDR block for public subnets"
  type        = map(string)
  default = {
    "ap-south-1a" = "10.0.1.0/24"
    "ap-south-1b" = "10.0.2.0/24"
  }
}

variable "priv_subnets" {
  description = "Map of AZ to CIDR block for private subnets"
  type        = map(string)
  default = {
    "ap-south-1a" = "10.0.10.0/24"
    "ap-south-1b" = "10.0.20.0/24"
  }
}

variable "cluster_name" {
  description = "EKS cluster name — used for required subnet tags"
  type        = string
}
