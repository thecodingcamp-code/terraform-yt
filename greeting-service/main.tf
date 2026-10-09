resource "aws_iam_role" "greeting_lambda" {
  name               = "greeting-service-lambda-role"
  assume_role_policy = file("${path.module}/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "greeting_logging" {
  role       = aws_iam_role.greeting_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "greeting" {
  type        = "zip"
  source_file = "${path.module}/handler.py"
  output_path = "${path.module}/greeting.zip"
}

resource "aws_cloudwatch_log_group" "greeting" {
  name              = "/aws/lambda/greeting-service"
  retention_in_days = 7
}

resource "aws_lambda_function" "greeting" {
  function_name    = "greeting-service"
  role             = aws_iam_role.greeting_lambda.arn
  runtime          = "python3.13"
  handler          = "handler.lambda_handler"
  filename         = data.archive_file.greeting.output_path
  source_code_hash = data.archive_file.greeting.output_base64sha256

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.greeting.name
  }

  environment {
    variables = {
      GREETING = var.greeting
    }
  }
}
