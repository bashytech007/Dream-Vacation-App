variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}