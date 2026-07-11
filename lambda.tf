# Package the Python file into a zip Terraform can upload
data "archive_file" "visitor_count_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/visitor_count.py"
  output_path = "${path.module}/lambda/visitor_count.zip"
}

# Role the Lambda assumes when it runs
resource "aws_iam_role" "lambda_role" {
  name = "cloud-resume-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Least-privilege policy: only this table, only the actions needed
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "cloud-resume-lambda-dynamodb"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

# Let Lambda write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# The function itself
resource "aws_lambda_function" "visitor_count" {
  function_name    = "cloud-resume-visitor-count"
  filename         = data.archive_file.visitor_count_zip.output_path
  source_code_hash = data.archive_file.visitor_count_zip.output_base64sha256
  handler          = "visitor_count.lambda_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_role.arn
}
