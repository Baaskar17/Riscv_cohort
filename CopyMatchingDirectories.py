import os
import shutil

def copy_matching_directories(root_directory, destination_directory):
    # Create destination directory if it doesn't exist
    os.makedirs(destination_directory, exist_ok=True)

    # Walk all subdirectories in the root directory
    for item in os.listdir(root_directory):
        item_path = os.path.join(root_directory, item)

        # Check if it is a directory and begins with test_v
        if os.path.isdir(item_path) and item.startswith("test_v"):
            dest_path = os.path.join(destination_directory, item)

            print(f"📁 Copying: {item_path} → {dest_path}")
            shutil.copytree(item_path, dest_path, dirs_exist_ok=True)

    print("✅ Finished copying matching directories.")

# ------ RUN ------

root_directory = input("Enter ROOT directory path: ").strip()
destination_directory = input("Enter DESTINATION directory path: ").strip()

copy_matching_directories(root_directory, destination_directory)
