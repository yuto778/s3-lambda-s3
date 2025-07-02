import json
import boto3
import os


# S3 の自動トリガー → Lambda でファイルを取得し、加工して別バケットに保存するサンプル

s3 = boto3.client('s3')
TARGET_BUCKET = os.environ['TARGET_BUCKET_NAME']

def lambda_handler(event, context):
    # SQS の各レコードをループ
    for sqs_record in event.get('Records', []):
        # body が JSON 文字列になっているのでロード
        body = json.loads(sqs_record['body'])

        print(json.dumps(body))

        # さらに body["Records"] に S3 イベント本体が入っている
        for s3_event in body.get('Records', []):
            source_bucket = s3_event['s3']['bucket']['name']
            source_key    = s3_event['s3']['object']['key']

            # S3 からオブジェクトを取得
            obj = s3.get_object(Bucket=source_bucket, Key=source_key)
            content = obj['Body'].read().decode('utf-8')

            # 簡易加工（大文字化）
            processed = content.upper()

            # 保存先キーを決定
            dest_key = 'text/' + source_key.rsplit('.', 1)[0] + '.txt'

            # 別バケットへアップロード
            s3.put_object(
                Bucket=TARGET_BUCKET,
                Key=dest_key,
                Body=processed.encode('utf-8'),
                ContentType='text/plain'
            )

            print(f"成功したよーn\ Copied s3://{source_bucket}/{source_key} → s3://{TARGET_BUCKET}/{dest_key}")

    return {
        "statusCode": 200,
        "body": json.dumps({ "message": "success" })
    }
    
