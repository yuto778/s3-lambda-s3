terraform {
  backend "s3" {
    bucket         = "terraform-state-215ad062"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-lock-215ad062"
    encrypt        = true
  }
}
