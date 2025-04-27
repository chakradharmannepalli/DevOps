variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "simple-web-app"
}

variable "container_image" {
  description = "Docker image for the ECS task"
  type        = string
  default     = "public.ecr.aws/docker/library/node:18" # Placeholder; update with your image
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}
