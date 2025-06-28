import json
import boto3
import os


# S3 の自動トリガー → Lambda でファイルを取得し、加工して別バケットに保存するサンプル

s3 = boto3.client('s3')
TARGET_BUCKET = os.environ['TARGET_BUCKET_NAME']

def lambda_handler(event, context):
    # 1. トリガー元バケット・キーの取得
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']

    # 2. S3 からオブジェクトを取得
    response = s3.get_object(Bucket=source_bucket, Key=source_key)
    content = response['Body'].read().decode('utf-8')

    # 3. 簡易加工例：全行を大文字化
    processed = content.upper()

    # 4. 保存先のバケットとキーを定義
    dest_bucket = TARGET_BUCKET  # ← デプロイ後に実際のバケット名に置き換えてください
    output_key = 'text/' + source_key.rsplit('.', 1)[0] + '.txt'

    # 5. 別バケットに加工後の内容をアップロード
    s3.put_object(
        Bucket=dest_bucket,
        Key=output_key,
        Body=processed.encode('utf-8'),
        ContentType='text/plain'
    )

    # 6. ログ出力
    print(f'Processed file saved to {dest_bucket}/{output_key}')

    print('成功したよー')

    return {
        'statusCode': 200,
        'body': json.dumps({
            "message":"success"
        })
    }

    
