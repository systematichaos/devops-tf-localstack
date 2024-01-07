data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/nodejs"
  output_path = local.lambda_zip_name

  depends_on = [
    random_string.r
  ]
}

resource "aws_s3_object" "this" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key = "lambda_zip_name.zip"
  source = data.archive_file.this.output_path
  etag = filemd5(data.archive_file.this.output_path)
}


resource "aws_iam_role" "this" {
  name = "${local.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "policy"
    policy = data.aws_iam_policy_document.this.json
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
}

resource "aws_lambda_function" "this" {
  function_name = "Helloworld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.this.key

  runtime = var.runtime
  handler = var.handler

  role = aws_iam_role.this.arn

}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.this.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}