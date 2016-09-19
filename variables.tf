# AWS variables
variable access_key { }
variable secret_key { }
variable region { }

variable vpc_cidr { }
variable tag_name { }
variable dhcp_domain_name { } # Dependent on the value of region
variable subnet_cidr { }

variable base_ami {
  type = "map"
  default = {
    us-east-1 = "ami-2ef48339"
    us-west-1 = "ami-a9a8e4c9"
    us-west-2 = "ami-746aba14"
  }
}

# Generate an SSH key and then put the text of the public key in values.tfvars
variable ssh_public_key { }

variable etcd_instance_type { }
variable controller_instance_type { }
variable worker_instance_type { }
