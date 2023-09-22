import json
import boto3

s3_bucket_name = "github-pr-metadata"
# check S3BucketAnalyzers

def lambda_handler(event, context):

    try:
        payload = json.loads(event['body'])
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid payload'})
        }

    if 'ref' in payload and payload['ref'] == 'refs/heads/main':
        repo_name = payload['repository']['name']
        commit = payload['head_commit']
        files = {
            'added': commit['added'],
            'modified': commit['modified'],
            'removed': commit['removed']
        }

        commit_id = commit['id']
        s3 = boto3.client('s3')
        filename = f"{repo_name}/{commit_id}"
        content = json.dumps(files)

        s3.put_object(
            Key=filename,
            Bucket=s3_bucket_name,
            Body=content
        )
        response = s3.get_object(Bucket=s3_bucket_name, Key=filename)
        file_content = response['Body'].read().decode('utf-8')

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Metadata saved to S3 bucket',
                                'bucket': s3_bucket_name,
                                'filename': filename,
                                'files': file_content })
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'No action required'})
    }