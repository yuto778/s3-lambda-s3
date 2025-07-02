variable "function_name" {
  type = string
}

variable "handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "source_bucket_arn" {
  type = string
}

variable "target_bucket_arn" {
  type = string
}

variable "target_bucket_name" {
  type = string
}

variable "sqs_queue_arn" {
  type = string

}
variable "sqs_queue_url" {
  type = string
}
