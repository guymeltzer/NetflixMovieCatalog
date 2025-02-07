from flask import Flask, request, jsonify
import boto3
from boto3.dynamodb.conditions import Key
import random

app = Flask(__name__)

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
main_table = dynamodb.Table('Guy-NetflixCatalog')
genre_table = dynamodb.Table('Guy-MoviesByGenre')

@app.route("/", methods=['GET'])
def home():
    return "Hi! This app is an API, there is no UI! ;-)"

@app.route('/discover')
def get_discover():
    """
    Find movies using over filters and sort options.
    """
    type_ = request.args.get('type')
    genre_id = request.args.get('genre')

    if not genre_id:
        # Random sampling from DynamoDB is not straightforward
        # This is a simplified approach and may not be efficient for large datasets
        scan_kwargs = {
            'ProjectionExpression': "movie_id, #type, #data",
            'ExpressionAttributeNames': {"#data": "data", "#type": "type"},
            'FilterExpression': "#type = :type_val",
            'ExpressionAttributeValues': {':type_val': type_ if type_ else 'movie'}
        }
        response = main_table.scan(**scan_kwargs)
        items = response['Items']
        results = random.sample(items, min(20, len(items)))
        return jsonify([item['data'] for item in results])
    else:
        genre_id = int(genre_id)
        response = genre_table.query(
            KeyConditionExpression=Key('genre_id').eq(genre_id),
            Limit=20
        )
        movie_ids = [item['movie_id'] for item in response['Items']]

        # Batch get full movie details
        response = dynamodb.batch_get_item(
            RequestItems={
                'Guy-NetflixCatalog': {
                    'Keys': [{'movie_id': mid} for mid in movie_ids],
                    'ProjectionExpression': "#data",
                    'ExpressionAttributeNames': {"#data": "data"}
                }
            }
        )
        return jsonify([item['data'] for item in response['Responses']['Guy-NetflixCatalog']])

@app.route('/updatePopularity', methods=['POST'])
def update_popularity():
    movie_id = request.json.get('movieId')
    new_popularity = request.json.get('popularity')

    if movie_id is None:
        return jsonify({'error': 'Movie Id value not provided'}), 400

    if new_popularity is None:
        return jsonify({'error': 'Popularity value not provided'}), 400

    try:
        movie_id = int(movie_id)
        new_popularity = float(new_popularity)
    except ValueError:
        return jsonify({'error': 'Invalid movie_id or popularity value'}), 400

    try:
        response = main_table.update_item(
            Key={'movie_id': movie_id},
            UpdateExpression="SET #data.popularity = :val",
            ExpressionAttributeNames={"#data": "data"},
            ExpressionAttributeValues={':val': new_popularity},
            ReturnValues="UPDATED_NEW"
        )
        return jsonify({'message': 'Popularity updated successfully', 'new_popularity': new_popularity}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/status')
def status():
    return 'OK!!'
#
if __name__ == '__main__':
    app.run(port=8080, host='0.0.0.0')
