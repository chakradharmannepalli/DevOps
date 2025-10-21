provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Create an ec2 Instance
resource "aws_instace" "example"{
  ami="ami-053b0d53c279acc90" # Specify an apporiate AMI ID
  instance_type= "t2.micro" # Provide your instance type
  subnet_id= "subnet-446411451454" # Provide you subnet ID
  key_name= "aws_key" # Provide your key name
}
