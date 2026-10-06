#!/usr/bin/env python3

import os
import sys
import argparse

AVB_MAGIC = b"AVB0"
AVB_MAGIC_LEN = 4

FLAGS_OFFSET = 123
FLAGS_TO_SET = b"\x03"


def patch_vbmeta(file):
    try:
        fd = os.open(file, os.O_RDWR)
    except OSError as e:
        sys.exit(f"Error opening file: {file}\n{e}")

    try:
        magic = os.read(fd, AVB_MAGIC_LEN)

        if magic != AVB_MAGIC:
            sys.exit(
                "Error: The provided image is not a valid vbmeta image.\n"
                "File not modified. Exiting..."
            )

        os.lseek(fd, FLAGS_OFFSET, os.SEEK_SET)

        written = os.write(fd, FLAGS_TO_SET)

        if written != len(FLAGS_TO_SET):
            sys.exit(
                "Error: Failed to write the complete flags data.\n"
                "File may be partially modified."
            )

    except OSError as e:
        sys.exit(f"Error: Failed when patching the vbmeta image.\n{e}")

    finally:
        os.close(fd)

    print("Patching successful.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Patch an Android vbmeta image."
    )
    parser.add_argument(
        "filename",
        help="vbmeta image file to patch"
    )

    args = parser.parse_args()
    patch_vbmeta(args.filename)
