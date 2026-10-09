import json
import os


def lambda_handler(event, context):
    name = event.get("name", "there")
    greeting = os.environ.get("GREETING", "Hello")
    return {
        "statusCode": 200,
        "body": json.dumps({"message": f"{greeting}, {name}!"}),
    }
