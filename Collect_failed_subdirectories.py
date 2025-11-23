import os
import shutil

def collect_failed_subdirectories(main_directory):
    # Create output directory inside main directory
    failed_dir = os.path.join(main_directory, "failed_subdirectories")
    os.makedirs(failed_dir, exist_ok=True)

    # Walk through subdirectories
    for root, dirs, files in os.walk(main_directory):
        # Skip the output directory itself to avoid infinite recursion
        if root.startswith(failed_dir):
            continue

        if "STATUS_FAILED" in files:
            subfolder_name = os.path.basename(root)
            destination = os.path.join(failed_dir, subfolder_name)

            print(f"📁 Copying failed subdirectory: {root}")
            shutil.copytree(root, destination, dirs_exist_ok=True)

    print("✅ Completed collecting failed subdirectories.")

# ---- RUN ----
main_directory = input("Enter main directory path: ").strip()
collect_failed_subdirectories(main_directory)
