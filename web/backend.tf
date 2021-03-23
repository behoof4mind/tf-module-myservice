terraform {
  backend "s3" {
    bucket = "terraform-my-service-state"
    key    = "terraform.tfstate"
    dynamodb_table = "terraform-my-service-state"
    encrypt        = true
  }
}