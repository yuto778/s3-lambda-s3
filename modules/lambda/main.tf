# Lambda用のIAMロール想定ポリシーを定義
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# IAMロールの作成
resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Lambdaの実行ポリシーを定義
# s3（ソース）の読み取り権限
# s3（ターゲット）への書き込み権限
# CloudWatch Logsへの出力権限
data "aws_iam_policy_document" "policy" {
  statement {
    sid     = "ReadSource"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "${var.source_bucket_arn}/*"
    ]
  }

  statement {
    sid     = "WriteTarget"
    actions = ["s3:PutObject"]
    resources = [
      "${var.target_bucket_arn}/*"
    ]
  }

  statement {
    sid     = "CloudWatchLogs"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

}

# 作成したポリシーをIAMポリシーとして登録
resource "aws_iam_policy" "this" {
  name   = "${var.function_name}-policy"
  policy = data.aws_iam_policy_document.policy.json
}

# IAMロールに対してポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# Lambda_fuction.pyをzip化
# 出力はfunction.zioに
data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/function.zip"
}

# Lambda関数のデプロイ設定
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.this.arn

  filename         = "${path.module}/function.zip"
  source_code_hash = data.archive_file.zip.output_base64sha256

  environment {
    variables = {
      TARGET_BUCKET      = var.target_bucket_arn
      TARGET_BUCKET_NAME = var.target_bucket_name
    }
  }

}
