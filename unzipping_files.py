import os
import zipfile

def extract_zip_files(root_directory):
    # Walk through all folders and files recursively
    for folder, subfolders, files in os.walk(root_directory):
        for filename in files:
            if filename.lower().endswith(".zip"):
                zip_path = os.path.join(folder, filename)
                print(f"Found ZIP: {zip_path}")

                try:
                    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                        zip_ref.extractall(folder)  # extract to same directory
                        print(f"Extracted: {zip_path}")
                except zipfile.BadZipFile:
                    print(f"⚠️ Skipping corrupted ZIP: {zip_path}")
                except Exception as e:
                    print(f"⚠️ Error extracting {zip_path}: {e}")

def main():
    root_directory = input("Enter directory to search for ZIP files: ").strip()

    if not os.path.isdir(root_directory):
        print("❌ Invalid directory. Please run again.")
        return

    extract_zip_files(root_directory)
    print("\n✔ Extraction completed.")

if __name__ == "__main__":
    main()
