
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "ami" {
    type = "map"
    
    default = {
        eu-west-2 = "ami-03dea29b0216a1e03"
        us-east-1 = "ami-0817d428a6fb68645"
    }
}

variable "public_key_path" {
  default="./london-region-key-pair.pub"
}

variable "private_key_path" {
default="london-region-key-pair"
}