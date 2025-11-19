import os
import zipfile
import shutil

# -----------------------------------------------------
# Find list.txt in ROOT + all subfolders
# -----------------------------------------------------
def find_list_file(root_directory, filename="list.txt"):

    # 1. Check ROOT directory first
    root_level_path = os.path.join(root_directory, filename)
    if os.path.isfile(root_level_path):
        return root_level_path

    # 2. Then check all subdirectories
    for root, dirs, files in os.walk(root_directory):
        if filename in files:
            return os.path.join(root, filename)

    return None


# -----------------------------------------------------
# Extract ZIP files
# -----------------------------------------------------
def extract_zip_files(root_directory):
    print("\n🔍 Searching and extracting ZIP files...\n")
    for root, dirs, files in os.walk(root_directory):
        for f in files:
            if f.lower().endswith(".zip"):
                zip_path = os.path.join(root, f)
                try:
                    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                        zip_ref.extractall(root)
                    print(f"✅ Extracted: {zip_path}")
                except zipfile.BadZipFile:
                    print(f"❌ Corrupted ZIP skipped: {zip_path}")


# -----------------------------------------------------
# Copy files listed in list.txt
# -----------------------------------------------------
def copy_listed_files(root_directory, output_directory, list_file_path):
    print("\n📁 Processing files from list.txt...\n")

    with open(list_file_path, "r", encoding="utf-8") as f:
        filenames = [line.strip() for line in f if line.strip()]

    found_any = False

    for name in filenames:
        file_found = False

        for root, dirs, files in os.walk(root_directory):
            for f in files:
                # match exact name or name without extension
                if f == name or f.split('.')[0] == name:
                    src_path = os.path.join(root, f)
                    out_folder = os.path.join(output_directory, os.path.splitext(name)[0])
                    os.makedirs(out_folder, exist_ok=True)

                    shutil.copy2(src_path, out_folder)
                    print(f"✅ Copied: {src_path} → {out_folder}")

                    file_found = True
                    found_any = True
                    break

            if file_found:
                break

        if not file_found:
            print(f"⚠️ WARNING: {name} not found anywhere in directory tree.")

    if not found_any:
        print("\n⚠️ No listed files were found at all!")


# -----------------------------------------------------
# MAIN PROGRAM
# -----------------------------------------------------
root_directory = input("Enter ROOT directory to search in: ").strip()
output_directory = input("Enter OUTPUT directory to copy files into: ").strip()

print("\n🔍 Searching for list.txt in ROOT and all subfolders...")
list_file_path = find_list_file(root_directory)

if not list_file_path:
    print("❌ ERROR: list.txt not found in ANY location!")
    input("\nPress ENTER to exit...")
    exit()

print(f"📄 list.txt found at: {list_file_path}")

extract_zip_files(root_directory)
copy_listed_files(root_directory, output_directory, list_file_path)

# Prevent console from closing
input("\nPress ENTER to exit...")
