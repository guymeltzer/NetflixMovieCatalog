import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
main_table = dynamodb.Table('Guy-NetflixCatalog')
genre_table = dynamodb.Table('Guy-MoviesByGenre')

def convert_floats(obj):
    """Recursively convert floats to Decimals"""
    if isinstance(obj, float):
        return Decimal(str(obj))
    if isinstance(obj, dict):
        return {k: convert_floats(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [convert_floats(x) for x in obj]
    return obj

def process_file(file_path, media_type):
    with open(file_path) as f:
        raw_data = json.load(f)
        data = convert_floats(raw_data)
        
        items = data.values()

        with main_table.batch_writer() as batch:
            with genre_table.batch_writer() as genre_batch:
                for item in items:
                    try:
                        # Common fields
                        item_id = item['id']
                        title = item.get('title') or item.get('name')  # Handle both movie/tv titles

                        # Write to main catalog
                        batch.put_item(Item={
                            'movie_id': item_id,
                            'type': media_type,
                            'data': item
                        })
                        
                        # Write genre mappings
                        for genre_id in item.get('genre_ids', []):
                            genre_batch.put_item(Item={
                                'genre_id': genre_id,
                                'movie_id': item_id,
                                'title': title  # Use combined title/name field
                            })
                            
                    except KeyError as e:
                        print(f"Skipping item due to missing key {e}: {item}")
                    except Exception as e:
                        print(f"Error processing item: {str(e)}")

# Process files with correct media types
process_file('data/data_movies.json', 'movie')  # Uses 'title' field
process_file('data/data_tv.json', 'tv')         # Uses 'name' field
