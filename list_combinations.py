import os
import re

def parse_opcodes(directory):
    instructions = []

    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            with open(filepath, 'r') as file:
                try:
                    for line in file:
                        line = line.strip()
                        if line and not line.startswith('#'):  # Skip empty lines and comments
                            # Extract mnemonic and fields (opcode, funct3, funct7)
                            parts = line.split()
                            mnemonic = parts[0] if parts else None
                            opcode_match = re.search(r"6\.\.2=([0-9a-fx]+)", line)
                            funct3_match = re.search(r"14\.\.12=([0-9a-fx]+)", line)
                            funct7_match = re.search(r"31\.\.25=([0-9a-fx]+)", line)

                            if mnemonic:
                                instruction = {"mnemonic": mnemonic}
                                if opcode_match:
                                    instruction["opcode"] = opcode_match.group(1)
                                if funct3_match:
                                    instruction["funct3"] = funct3_match.group(1)
                                if funct7_match:
                                    instruction["funct7"] = funct7_match.group(1)
                                instructions.append(instruction)
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
    return instructions

def save_to_file(instructions, output_file):
    with open(output_file, 'w') as file:
        for instruction in instructions:
            line = f"{instruction['mnemonic']}"
            if "opcode" in instruction:
                line += f", opcode: {instruction['opcode']}"
            if "funct3" in instruction:
                line += f", funct3: {instruction['funct3']}"
            if "funct7" in instruction:
                line += f", funct7: {instruction['funct7']}"
            file.write(line + '\n')

def main():
    directory = '/home/vsysuser/workspace/riscv-opcodes/extensions'
    output_file = '/home/vsysuser/workspace/Riscv_cohort/extension_counts.csv'
    instructions = parse_opcodes(directory)
    for instruction in instructions:
        print(instruction)
    save_to_file(instructions, output_file)

if __name__ == '__main__':
    main()
