import json
import boto3
import pytest
from moto import mock_aws

TABLE_NAME = "cloud-resume-visitor-count"


@pytest.fixture
def dynamodb_table():
    """Spin up a fake DynamoDB table before each test, tear it down after."""
    with mock_aws():
        client = boto3.resource("dynamodb", region_name="us-east-2")
        table = client.create_table(
            TableName=TABLE_NAME,
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        table.put_item(Item={"id": "visitor_count", "count": 0})
        yield table


def test_first_visit_returns_one(dynamodb_table):
    """A single visit should increment the count from 0 to 1."""
    import visitor_count
    response = visitor_count.lambda_handler({}, {})

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["count"] == 1


def test_count_increments_each_visit(dynamodb_table):
    """Three visits should leave the count at 3."""
    import visitor_count
    visitor_count.lambda_handler({}, {})
    visitor_count.lambda_handler({}, {})
    response = visitor_count.lambda_handler({}, {})

    body = json.loads(response["body"])
    assert body["count"] == 3


def test_cors_header_present(dynamodb_table):
    """Response must include the CORS header so the browser accepts it."""
    import visitor_count
    response = visitor_count.lambda_handler({}, {})

    assert response["headers"]["Access-Control-Allow-Origin"] == "*"
