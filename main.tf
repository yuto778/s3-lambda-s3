# プロバイダー設定
provider "aws" {
  region = var.region
}

#ランダム変数の生成
resource "random_id" "suffix" {
  byte_length = 4
}

# ソース用s3バケット
module "source_s3" {
  source        = "./modules/s3"
  bucket_name   = "${var.source_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
}

# ターゲット用s3バケット
module "target_s3" {
  source        = "./modules/s3"
  bucket_name   = "${var.target_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
}

# SQS
module "event_queue" {
  source            = "./modules/sqs"
  queue_name        = "${var.project_name}-queue"
  source_bucket_arn = module.source_s3.bucket_arn
}

# Lambda関数
module "processor_lambda" {
  source             = "./modules/lambda"
  function_name      = "${var.project_name}-processor"
  handler            = "lambda_function.lambda_handler"
  runtime            = "python3.9"
  source_bucket_arn  = module.source_s3.bucket_arn
  target_bucket_arn  = module.target_s3.bucket_arn
  target_bucket_name = module.target_s3.bucket_id
  sqs_queue_arn      = module.event_queue.queue_arn
  sqs_queue_url      = module.event_queue.queue_url

}

# s3バケット通知設定
# ソースs3バケットにオブジェクトが作成されたらLambda関数を呼び出す
# depends_onでLambdaの実行許可(aws_lambda_permission)の作成を待機
# resource "aws_s3_bucket_notification" "notify" {
#   bucket = module.source_s3.bucket_id
#   lambda_function {
#     lambda_function_arn = module.processor_lambda.function_arn
#     events              = ["s3:ObjectCreated:*"]
#   }

#   depends_on = [aws_lambda_permission.allow_s3]

# }

# s3からの呼び出しを許可するLambda権限設定
# resource "aws_lambda_permission" "allow_s3" {
#   statement_id  = "AllowExecutionFromS3"
#   action        = "lambda:InvokeFunction"
#   function_name = module.processor_lambda.function_arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = module.source_s3.bucket_arn
# }

resource "aws_s3_bucket_notification" "to_sqs" {
  bucket = module.source_s3.bucket_id

  queue {
    queue_arn = module.event_queue.queue_arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [module.event_queue] # SQSが作成されてから通知設定を行うため
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = module.event_queue.queue_arn
  function_name    = module.processor_lambda.function_arn
  enabled          = true
  batch_size       = 5
}

