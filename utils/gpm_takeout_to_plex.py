#!/usr/bin/env python
# a small script to transform files from a takeouts.google.com export of
# Google Play Music to a plex music library structure, given the pending
# shutdown of Google Play Music
import os
import json
import subprocess
import shutil
import argparse


def get_file_metadata(filepath):
    return json.loads(subprocess.check_output([
        "ffprobe",
        "-v", "quiet", "-print_format", "json",
        "-show_format", "-show_format_entry", "tags",
        filepath,
    ]))["format"]["tags"]


def relative_path_for_metadata(metadata):
    return os.path.join(
        # https://support.plex.tv/articles/200265296-adding-music-media-from-folders/
        metadata.get("album_artist", "Various Artists"),
        metadata["album"],
        metadata["track"].split("/")[0] + " - " + metadata["title"] + ".mp3",
    )

def __main(args):
    source_base_dir=args.takeout_path
    target_dir=args.output_dir
    dry_run=args.dry_run
    # Music is in ./Google Play Music/Tracks under the extracted Takeout
    data_dir = os.path.join(source_base_dir, "Google Play Music", "Tracks")
    # walk files in directory
    (_, _, filenames) = next(os.walk(data_dir))
    for filename in filenames:
        file_path = os.path.join(data_dir, filename)
        # skip files that are not music for now
        if not file_path.endswith(".mp3"):
            continue
        # get the path from the metadata
        try:
            metadata = get_file_metadata(file_path)
            proposed_path = os.path.join(target_dir, relative_path_for_metadata(metadata))
        except Exception as e:
            print("failed to get path from metadata for file: "+file_path)
            print(e)
            continue
        # show the updated path
        print(file_path + " => " + proposed_path)
        # if dry running, stop here for this file
        if dry_run:
            continue
        # ensure the directory exists
        os.makedirs(os.path.dirname(proposed_path))
        # copy the file, preserving metdata
        shutil.copy2(file_path, proposed_path)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("ttakeout-path", help="Path to extracted 'Takeout' directory")
    parser.add_argument("output-path", help="Path to music library directory to output files too")
    parser.add_argument("dry-run", type=bool, help="if set, do not actually take action")
    args = parser.parse_args()
    __main(args)

main()

