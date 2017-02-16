#!/usr/bin/env python

"""
symlinks all files in ./tilde to ~/
"""

#TODO: dry run flag
#TODO: probably don't use system to symlink

import os
import errno

def remove_prefix(prefix, path):
    n = len(prefix) + len(os.path.sep)
    return path[path.find(prefix)+n:]

def ask_yes_no(query):
    input = raw_input(query+" (y/n): ")
    while input != "y" and input != "n":
        input = raw_input("please enter 'y' or 'n': ")
    return input == "y"

def main():
    # path to this file's dir ./tilde
    path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "tilde")
    home = os.path.expanduser("~")
    # walk files in ./tilde
    for dirpath, dirnames, files in os.walk(path):
        for f in files:
            # symlink f in ~/
            source = os.path.join(dirpath, f)
            relative = remove_prefix(path, source)
            link_path = os.path.join(home, relative)
            print "Symlink: %s -> %s" % (source, link_path)
            try:
                os.makedirs(link_path)
            except:
                pass
            os.system("ln -fs %s %s" % (source, link_path))

if __name__ == "__main__":
    main()
