#! /usr/bin/env python

"""
A simple utility for managing the creation and deployment of cscope index
files.
"""

import argparse

cmd_list=("join", "list-cfgs", "cfg-path")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cmd",
                        help="The operation to perform",
                        choices=cmd_list,
                        default="join")
    parser.add_argument("-c", "--config",
                        help="Specify the configuration to use.",
                        default="basic")
    args = parser.parse_args()
