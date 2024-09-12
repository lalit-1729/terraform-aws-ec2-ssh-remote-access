# AMI DATASOURCE
# A data source is a way to fetch or reference existing information that is managed outside of your 
# Terraform configuration. This information could be managed by Terraform itself or by other systems (AWS, GCP, etc.). Data sources allow you to read data from external sources without having to create or modify them, making it easier to interact with existing infrastructure or resources.


data "aws_ami" "terraform_ami_datasource" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
