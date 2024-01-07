locals {
  apigateway_name = var.name
  function_name   = var.name
  lambda_zip_name = "${path.module}/lambda.${random_string.r.result}.zip"
}

resource "random_string" "r" {
  length  = 16
  special = false
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "asmin-lambda-test-bucket"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.this.invoke_arn}"
}