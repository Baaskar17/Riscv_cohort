import os
import shutil

def copytree_skip_ref(src, dst):
    """
    Custom copytree function that skips the 'ref' subdirectory.
    """
    for root, dirs, files in os.walk(src):
        # Remove 'ref' from directories so walk skips it
        if 'ref' in dirs:
            dirs.remove('ref')

        # Determine destination path
        rel_path = os.path.relpath(root, src)
        dest_path = os.path.join(dst, rel_path)

        os.makedirs(dest_path, exist_ok=True)

        # Copy files
        for file in files:
            src_file = os.path.join(root, file)
            dst_file = os.path.join(dest_path, file)
            shutil.copy2(src_file, dst_file)

def process_co_directories(parent_dir, destination_dir):
    # Create destination directory if missing
    os.makedirs(destination_dir, exist_ok=True)

    # Traverse co-directories in the parent directory
    for co_name in os.listdir(parent_dir):
        co_path = os.path.join(parent_dir, co_name)

        if not os.path.isdir(co_path):
            continue

        dut_path = os.path.join(co_path, "dut")

        # Check if dut exists
        if os.path.isdir(dut_path):
            print(f"🔧 Processing co-directory: {co_name}")

            # Rename ELF files to co_name.elf
            for file in os.listdir(dut_path):
                if file.endswith(".elf"):
                    old_path = os.path.join(dut_path, file)
                    new_path = os.path.join(dut_path, f"{co_name}.elf")
                    print(f"   📝 Renaming {file} → {co_name}.elf")
                    os.rename(old_path, new_path)

            # Copy co-directory to destination (skip 'ref')
            dest_path = os.path.join(destination_dir, co_name)
            print(f"   📁 Copying → {dest_path}")
            copytree_skip_ref(co_path, dest_path)

    print("✅ Completed Problem 5.")


# -------- RUN SCRIPT --------

parent_dir = input("Enter PARENT directory path: ").strip()
destination_dir = input("Enter DESTINATION directory path: ").strip()

process_co_directories(parent_dir, destination_dir)
