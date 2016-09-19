provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "kubernetes" {
  cidr_block = "${var.vpc_cidr}"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_vpc_dhcp_options" "kubernetes" {
  domain_name = "${var.dhcp_domain_name}"

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_vpc_dhcp_options_association" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kubernetes.id}"
}

resource "aws_subnet" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"
  cidr_block = "${var.subnet_cidr}"

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_internet_gateway" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_route_table" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kubernetes.id}"
  }

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_security_group" "kubernetes" {
  name = "kuberenetes_sg"
  description = "Kubernetes security group"
  vpc_id = "${aws_vpc.kubernetes.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_iam_role" "kubernetes" {
  name = "${var.tag_name}"
  assume_role_policy = "${file("${path.module}/iam_roles/kubernetes_iam_role.json")}"
}

resource "aws_iam_role_policy" "kubernetes" {
  name = "${var.tag_name}"
  role = "${aws_iam_role.kubernetes.id}"
  policy = "${file("${path.module}/iam_roles/kubernetes_iam_policy.json")}"
}

resource "aws_iam_instance_profile" "kubernetes" {
  name = "${var.tag_name}"
  roles = ["${aws_iam_role.kubernetes.id}"]
}

resource "aws_key_pair" "kubernetes" {
  key_name = "${var.tag_name}"
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "etcd0" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.etcd_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.10"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  associate_public_ip_address = true

  tags {
    Name = "etcd0"
  }
}

resource "aws_instance" "etcd1" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.etcd_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.11"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  associate_public_ip_address = true

  tags {
    Name = "etcd1"
  }
}

resource "aws_instance" "etcd2" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.etcd_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.12"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  associate_public_ip_address = true

  tags {
    Name = "etcd2"
  }
}

resource "aws_instance" "controller0" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.controller_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.20"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.kubernetes.name}"
  source_dest_check = false
  associate_public_ip_address = true

  tags {
    Name = "controller0"
  }
}

resource "aws_instance" "controller1" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.controller_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.21"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.kubernetes.name}"
  source_dest_check = false
  associate_public_ip_address = true

  tags {
    Name = "controller1"
  }
}

resource "aws_instance" "controller2" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.controller_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.22"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.kubernetes.name}"
  source_dest_check = false
  associate_public_ip_address = true

  tags {
    Name = "controller2"
  }
}

resource "aws_instance" "worker0" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.worker_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.30"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.kubernetes.name}"
  source_dest_check = false
  associate_public_ip_address = true

  tags {
    Name = "worker0"
  }
}

resource "aws_instance" "worker1" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.worker_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.31"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.kubernetes.name}"
  source_dest_check = false
  associate_public_ip_address = true

  tags {
    Name = "worker1"
  }
}

resource "aws_instance" "worker2" {
  ami = "${lookup(var.base_ami, var.region)}"
  instance_type = "${var.worker_instance_type}"
  subnet_id = "${aws_subnet.kubernetes.id}"
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  private_ip = "10.240.0.32"
  key_name = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.kubernetes.name}"
  source_dest_check = false
  associate_public_ip_address = true

  tags {
    Name = "worker2"
  }
}

resource "aws_elb" "kubernetes" {
  name = "kubernetes-lb"
  subnets = ["${aws_subnet.kubernetes.*.id}"]
  security_groups = ["${aws_security_group.kubernetes.id}"]

  instances = [
    "${aws_instance.controller0.id}",
    "${aws_instance.controller1.id}",
    "${aws_instance.controller2.id}"
  ]

  listener {
    instance_port = 6443
    instance_protocol = "tcp"
    lb_port = 6443
    lb_protocol = "tcp"
  }

  tags {
    name = "${var.tag_name}"
  }
}
