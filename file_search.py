import os
import shutil

def find_file(root_directory, target_filename):
    # Walk through directories recursively
    for folder, subfolders, files in os.walk(root_directory):
        if target_filename in files:
            return os.path.join(folder, target_filename)
    return None

def copy_listed_files(root_directory, output_directory, file_list):
    for filename in file_list:
        print(f"\nSearching for: {filename}")

        found_path = find_file(root_directory, filename)

        if found_path:
            print(f"✔ Found: {found_path}")

            # Folder name = filename without extension
            folder_name = os.path.splitext(filename)[0]
            destination_folder = os.path.join(output_directory, folder_name)

            os.makedirs(destination_folder, exist_ok=True)

            destination_file = os.path.join(destination_folder, filename)
            shutil.copy2(found_path, destination_file)

            print(f"📂 Copied to: {destination_file}")

        else:
            print(f"⚠️ Warning: {filename} not found!")

def main():
    root_directory = input("Enter ROOT directory to search in: ").strip()
    output_directory = input("Enter OUTPUT directory to copy files into: ").strip()
    list_file = input("Enter path to the text file that contains filenames: ").strip()

    if not os.path.isdir(root_directory):
        print("❌ Invalid root directory.")
        return

    if not os.path.isdir(output_directory):
        print("❌ Invalid output directory.")
        return

    if not os.path.isfile(list_file):
        print("❌ List file not found.")
        return

    # Read filenames from file list
    with open(list_file, "r") as f:
        file_list = [line.strip() for line in f if line.strip()]

    copy_listed_files(root_directory, output_directory, file_list)

    print("\n✔ Processing complete.")

if __name__ == "__main__":
    main()
