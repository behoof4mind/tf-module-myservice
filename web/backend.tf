terraform {
  backend "s3" {
    bucket = "terraform-my-service-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
    access_key = "ACCESS_KEY_VAR"
    secret_key = "SECRET_KEY_VAR"
    dynamodb_table = "terraform-my-service-state"
    encrypt        = true
  }
}