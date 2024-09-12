resource "aws_vpc" "terraform_vpc" {
  cidr_block = "178.168.0.0/16"
  tags = {
    Name = "vpc_on_aws"
  }
}

resource "aws_subnet" "terraform_vpc_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "178.168.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "public_subnet_on_aws"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "igw_on_aws"
  }
}

resource "aws_route_table" "terraform_rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "rt_on_aws"
  }
}

resource "aws_route" "terraform_igw_route" {
  route_table_id         = aws_route_table.terraform_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terraform_igw.id
}

resource "aws_route_table_association" "terraform_rt_association" {
  subnet_id      = aws_subnet.terraform_vpc_subnet.id
  route_table_id = aws_route_table.terraform_rt.id
}

resource "aws_security_group" "terraform_sg" {
  name        = "sg_on_aws"
  description = "Terraform Security Group"
  vpc_id      = aws_vpc.terraform_vpc.id

  tags = {
    Name = "sg_on_aws"
  }
}

# ingress refers to traffic entering a system or network,
resource "aws_security_group_rule" "terraform_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  #   cidr_blocks = ["x.x.x.x/32"] 
  # replace it with you ip address to restrict access to you only
  cidr_blocks = ["0.0.0.0/0"] # for all public access

  security_group_id = aws_security_group.terraform_sg.id
}

# egress refers to traffic leaving a system or network
resource "aws_security_group_rule" "terraform_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.terraform_sg.id
}


# key pair for remote access
resource "aws_key_pair" "terrafrom_key_pair" {
  key_name   = "ssh_key_on_aws"
  public_key = file("~/.ssh/<your_access_key>.pub")
}


resource "aws_instance" "terraform_ec2" {
  ami                    = data.aws_ami.terraform_ami_datasource.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.terraform_vpc_subnet.id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  key_name               = aws_key_pair.terrafrom_key_pair.id # id == key_name = true
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "ec2_intance_on_aws"
  }

  # The local-exec provisioner invokes a local executable after a resource is created. 
  # This invokes a process on the machine running Terraform, not on the resource.
  provisioner "local-exec"{
    # this tpl script will work for linux and macOS only.
    command = templatefile("ssh-config.tpl", {
      HOSTNAME =  self.public_ip,
      USER  = "ubuntu",
      identityFile = "~/.ssh/<your_key_name>"
    })
    interpreter = ["bash", "-c"]
  }
}

# terraform plan
# terraform apply
# terraform destroy OR terraform apply -destroy
# terraform apply -replace <resources-name> <- to Replace a single resource
# -auto-approve <- to bypass the confirmation
# terraform state list <- lists the content of the terrafform state
# terraform state show <state-item-name> <- describes the state configuration
# terraform show <- will show the entire state
# More about state => https://developer.hashicorp.com/terraform/language/state
# terraform fmt -> to format the document/scripts

# ssh -i ~/.ssh/aws_ass_key ubuntu@<public-ip-of-ec2-instance> 
# use -v for verbose logs
