output "s3_source_bucket_id" {
  value = module.source_s3.bucket_id
}
output "s3_target_bucket_id" {
  value = module.target_s3.bucket_id
}

output "event_queue_url" {
  value = module.event_queue.queue_url
}

output "lambda_function_name" {
  value = module.processor_lambda.function_name
}
