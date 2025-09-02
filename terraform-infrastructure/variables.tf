# In variables.tf

variable "public_key_content" {
  description = "The public key for EC2 instances"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}