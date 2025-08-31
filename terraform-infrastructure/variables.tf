# Update your variables.tf
variable "public_key_content" {
  description = "Content of the SSH public key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}