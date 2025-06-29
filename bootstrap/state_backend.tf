provider "aws" {
  region = "ap-northeast-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${random_id.suffix.hex}"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-${random_id.suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_state_bucket_id" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_lock_table_id" {
  value = aws_dynamodb_table.terraform_lock.id
}
