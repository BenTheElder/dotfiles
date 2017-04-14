#!/usr/bin/env python

"""
script to fetch and install the latest version of go
this currently requires python2.7

USE AT YOUR OWN RISK.
"""

# TODO: support getting other versions and arches, etc.
# TODO: get and check hashes
# TODO: support windows?

import re
import urllib
import platform
from sys import platform as sys_platform
import os

def get_go_versions():
    data = urllib.urlopen('https://go.googlesource.com/go/+refs').read()
    res = set()
    for match in re.finditer('go([0-9]+).([0-9]+).([0-9]+)?', data):
        res.add(tuple((int(x) for x in match.groups() if x is not None)))
    return sorted(res)[::-1]

def ask_yes_no(query):
    input = raw_input(query+" (y/n): ")
    while input.lower() not in ["y", "n"]:
        input = raw_input("please enter 'y' or 'n': ")
    return input.lower() == "y"

def get_goos_and_arch():
    # TODO: support possible other systems
    platform_to_goos = {
        "linux2": "linux",
        "linux": "linux",
        "darwin": "darwin",
        "win32": "windows",
    }
    goos = platform_to_goos[sys_platform]
    arch_to_goarch = {
        "32bit": "386",
        "64bit": "amd64",
    }
    goarch = arch_to_goarch[platform.architecture()[0]]
    return (goos, goarch)

def fetch_file(url, filename):
    urllib.URLopener().retrieve(url, filename)

def main():
    # get go versions and print latest
    print "Fetching go versions..."
    versions = get_go_versions()
    newest = versions[0]
    version = ".".join(map(str, newest))
    print "The latest version is: " + version
    # get os and arch in go format
    goos, goarch = get_goos_and_arch()
    tar_name = "go"+version+"."+goos+"-"+goarch+".tar.gz"
    # ask if user actually wants to install distribution selected
    if not ask_yes_no("Install '"+tar_name+"' ?"):
        print "Exiting."
        return
    # fetch tarfile distribution
    print "Fetching '"+tar_name+"' ..."
    fetch_file("https://storage.googleapis.com/golang/"+tar_name, tar_name)
    # remove previous installation    
    print "removing /usr/local/go"
    os.system("rm -rf /usr/local/go")
    # expand new distribution
    print "untarring to /usr/local"
    os.system("tar -C /usr/local -xzf"+tar_name)
    # delete tarfile
    print "deleting tarfile"
    os.system("rm "+tar_name)
    # remind user to set $PATH
    print "make sure: `export PATH=$PATH:/usr/local/go/bin` is in your bash profile."

if __name__ == "__main__":
    main()
