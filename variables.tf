variable "region" {
  default = "ap-northeast-1"
}

variable "project_name" {
  default = "myapp-s3-lambda"
}

variable "source_bucket_name" {
  type    = string
  default = "myapp-source-bucket"
}

variable "target_bucket_name" {
  type    = string
  default = "myapp-target-bucket"
}
