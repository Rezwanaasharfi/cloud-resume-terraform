resource "aws_dynamodb_table_item" "visitor_count_init" {
  table_name = aws_dynamodb_table.visitor_count.name
  hash_key   = aws_dynamodb_table.visitor_count.hash_key

  item = <<ITEM
{
  "id": {"S": "visitor_count"},
  "count": {"N": "0"}
}
ITEM
}
