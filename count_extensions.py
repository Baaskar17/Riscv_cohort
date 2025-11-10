import os
import csv

def count_instructions(directory):
    extension_counts = {}

    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            with open(filepath, 'r') as file:
                instruction_count = 0
                for line in file:
                    line = line.strip()
                    if line and not line.startswith(('#', ';')):
                        parts = line.split()
                        if parts:
                            instruction_count += 1
                extension_name = os.path.splitext(filename)[0]
                extension_counts[extension_name] = instruction_count

    return extension_counts

def save_to_csv(data, output_file):
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Extension', 'Instruction Count'])
        for extension, count in data.items():
            writer.writerow([extension, count])

def print_table(data):
    print(f"{'Extension':<20}{'Instruction Count':<20}")
    print("-" * 40)
    for extension, count in data.items():
        print(f"{extension:<20}{count:<20}")

def main():
    directory = '/home/vsysuser/workspace/riscv-opcodes/extensions'
    output_file = '/home/vsysuser/workspace/Riscv_cohort/extension_counts.csv'

    extension_counts = count_instructions(directory)
    print_table(extension_counts)
    save_to_csv(extension_counts, output_file)

    print(f"\nResults saved to {output_file}.")

if __name__ == '__main__':
    main()
