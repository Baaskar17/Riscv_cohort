import os
import re
from collections import defaultdict

def parse_opcodes(directory):
    opcode_frequencies = defaultdict(list)

    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            with open(filepath, 'r') as file:
                try:
                    for line in file:
                        line = line.strip()
                        if line and not line.startswith(('#', '//', ';', '$')):  # Skip comments and pseudo-ops
                            # Extract opcode (6..0 or 6..2)
                            opcode_match = re.search(r"6\.\.0=([0-9a-fx]+)|6\.\.2=([0-9a-fx]+)", line)
                            if opcode_match:
                                opcode = opcode_match.group(1) or opcode_match.group(2)
                                mnemonic = line.split()[0]  # First word is the mnemonic
                                opcode_frequencies[opcode].append(mnemonic)
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
    return opcode_frequencies

def save_to_file(opcode_frequencies, output_file):
    with open(output_file, 'w') as file:
        for opcode, mnemonics in opcode_frequencies.items():
            file.write(f"Opcode: {opcode}\n")
            file.write(f"Mnemonics: {', '.join(mnemonics)}\n")
            file.write("\n")

def print_frequencies(opcode_frequencies):
    print(f"{'Opcode':<10}{'Mnemonics'}")
    print("-" * 40)
    for opcode, mnemonics in opcode_frequencies.items():
        print(f"{opcode:<10}{', '.join(mnemonics)}")

def main():
    directory = '/home/vsysuser/workspace/riscv-opcodes/extensions'
    output_file = '/home/vsysuser/workspace/Riscv_cohort/opcode_frequencies.txt'

    opcode_frequencies = parse_opcodes(directory)
    print_frequencies(opcode_frequencies)
    save_to_file(opcode_frequencies, output_file)

    print(f"\nResults saved to {output_file}.")

if __name__ == '__main__':
    main()
