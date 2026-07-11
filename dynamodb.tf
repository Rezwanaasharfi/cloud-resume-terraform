resource "aws_dynamodb_table" "visitor_count" {
  name         = "cloud-resume-visitor-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "cloud-resume-terraform"
  }
}
