terraform {
  backend "s3" {
    bucket         = "dream-cationterraform-state"      # <-- IMPORTANT: Use your bucket name
    key            = "global/terraform.tfstate"  # This is the path to the state file inside the bucket
    region         = "us-east-1"                 # IMPORTANT: Use the same region as your bucket
    dynamodb_table = "terraform-state-locks"     # <-- IMPORTANT: Use your DynamoDB table name
    encrypt        = true
  }
}