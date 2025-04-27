variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}
