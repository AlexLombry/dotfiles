import json
import sys

def fix_json(input_string):
    try:
        # Directly try to load the JSON
        valid_json = json.loads(input_string)
        return json.dumps(valid_json, indent=4)
    except json.JSONDecodeError as e:
        # Handle common JSON errors (like trailing commas)
        if 'Expecting property name enclosed in double quotes' in str(e) or 'Expecting value' in str(e):
            # This is a simplistic fix and might not work for all cases
            corrected_string = input_string.replace(",}", "}").replace(",]", "]")
            return fix_json(corrected_string)
        else:
            raise

def main():
    if len(sys.argv) != 2:
        print("Usage: python fix_json.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    try:
        with open(filename, 'r') as file:
            json_data = file.read()
            fixed_json = fix_json(json_data)
            print(fixed_json)  # Print the fixed JSON to the console
            # Optionally, write the fixed JSON back to a file
            # with open('fixed_' + filename, 'w') as output_file:
            #     output_file.write(fixed_json)
    except FileNotFoundError:
        print(f"File not found: {filename}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()

