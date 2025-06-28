variable "bucket_name" {
  type        = string
  description = "作成するs3バケットの名前"
}

variable "is_versioning" {
  type    = bool
  default = false
}

variable "force_destroy" {
  type    = bool
  default = false
}
