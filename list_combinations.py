import csv
import json

def extract_fields(input_file):
    fields = []

    with open(input_file, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) >= 3:  # Ensure the row has at least 3 columns
                field_name = row[0].strip('"')  # Remove quotes around the field name
                start_bit = row[1].strip()
                end_bit = row[2].strip()
                fields.append({
                    "field_name": field_name,
                    "start_bit": start_bit,
                    "end_bit": end_bit
                })

    return fields

def save_to_json(data, output_file):
    with open(output_file, 'w') as file:
        json.dump(data, file, indent=4)

def main():
    directory = '/home/vsysuser/workspace/riscv-opcodes/extensions'
    output_file = '/home/vsysuser/workspace/Riscv_cohort/combination.json'

    fields = extract_fields(input_file)
    save_to_json(fields, output_file)

    print(f"Extracted {len(fields)} fields and saved to {output_file}.")

if __name__ == '__main__':
    main()
