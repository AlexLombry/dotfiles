import csv
import json

def csv_to_json(csv_file_path, json_file_path):
    # Initialize the data container
    data = []

    # Open and read the CSV file
    with open(csv_file_path, mode='r', encoding='utf-8') as csv_file:
        csv_reader = csv.DictReader(csv_file)

        # Convert each row into a dictionary and add it to the data
        for row in csv_reader:
            data.append(row)

    # Write the data to a JSON file
    with open(json_file_path, mode='w', encoding='utf-8') as json_file:
        json.dump(data, json_file, indent=4)

# Specify the path to the CSV file and the output JSON file path
csv_file_path = 'meta_DE.csv'
json_file_path = 'meta_DE.json'

# Call the function to convert CSV to JSON
csv_to_json(csv_file_path, json_file_path)
