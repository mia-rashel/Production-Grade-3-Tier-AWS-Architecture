terraform {
  backend "s3" {
    bucket         = "mia-terraform-state-bucket-26"
    key            = "multi-tier/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}