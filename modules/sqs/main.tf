resource "aws_sqs_queue" "this" {
  name = var.queue_name
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowS3SendMessage",
        Effect    = "Allow",
        Principal = { Service = "s3.amazonaws.com" },
        Action    = "SQS:SendMessage",
        Resource  = aws_sqs_queue.this.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.source_bucket_arn
          }
        }
      }
    ]
  })
}
