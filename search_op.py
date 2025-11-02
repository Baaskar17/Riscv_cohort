import os
import re
import json

def search_mnemonics(directory, query, case_insensitive=False):
    results = []
    # Always escape query → literal search only
    pattern = re.escape(query)
    flags = re.IGNORECASE if case_insensitive else 0

    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as file:
                    for line_number, line in enumerate(file, start=1):
                        line = line.strip()
                        if line and not line.startswith(('#', ';')):
                            if re.search(pattern, line, flags):
                                results.append({
                                    "filename": filename,
                                    "line_number": line_number,
                                    "matched_text": line
                                })
            except Exception as e:
                print(f"Error reading {filename}: {e}")
    return results

def save_results(results, output_file):
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=4, ensure_ascii=False)

def main():
    directory = '/home/vsysuser/workspace/riscv-opcodes/extensions'
    output_file = '/home/vsysuser/workspace/Riscv_cohort/search.json'

    print("RISC-V Opcode Search Tool (Literal Text Only)\n")

    query = input("Enter the mnemonic to search: ").strip()
    if not query:
        print("Error: Query cannot be empty.")
        return

    case_choice = input("Case-insensitive search? (y/n): ").strip().lower()
    case_insensitive = case_choice == 'y'

    print(f"\nSearching for: '{query}'")
    print(f"Case-insensitive: {case_insensitive}\n")

    results = search_mnemonics(directory, query, case_insensitive)
    save_results(results, output_file)

    print(f"Search complete. Results saved to {output_file}")
    if results:
        print(f"\nFound {len(results)} match(es):")
        for r in results:
            print(f"  {r['filename']} (Line {r['line_number']}): {r['matched_text']}")
    else:
        print("No matches found.")

if __name__ == '__main__':
    main()
