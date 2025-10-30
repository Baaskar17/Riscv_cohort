
import os

def parse_opcodes(directory):
    mnemonics = set()
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            with open(filepath, 'r') as file:
                try:
                    for line in file:
                        line = line.strip()
                        if line and not line.startswith('#'):
                            parts = line.split()
                            if parts:
                                mnemonics.add(parts[0])
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
    return sorted(mnemonics)

def save_to_file(mnemonics, output_file):
    with open(output_file, 'w') as file:
        for mnemonic in mnemonics:
            file.write(mnemonic + '\n')

def main():
    directory = 'extensions'
    output_file = 'all_opcodes.txt'
    mnemonics = parse_opcodes(directory)
    print("\n".join(mnemonics))
    save_to_file(mnemonics, output_file)

if __name__ == '__main__':
    main()
