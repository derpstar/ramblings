provider "aws" {
  region = "us-east-1"
  # Your AWS credentials, if not set externally.
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
}

resource "aws_kinesis_stream" "example" {
  name        = "example"
  shard_count = 1
}

resource "aws_iam_role" "cloudwatch_role" {
  name = "CloudwatchKinesisRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "logs.region.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_kinesis_policy" {
  name        = "CloudwatchKinesisPolicy"
  description = "My policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      Effect   = "Allow",
      Resource = aws_kinesis_stream.example.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_kinesis_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_kinesis_policy.arn
  role       = aws_iam_role.cloudwatch_role.name
}
