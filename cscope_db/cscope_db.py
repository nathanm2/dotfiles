#! /usr/bin/env python

"""
A simple utility for managing the creation and deployment of cscope index
files.
"""

import argparse
import sys
import os
import inspect

def script_dir():
    """ Get the path of THIS script."""
    return os.path.dirname(os.path.abspath(inspect.getfile(
        inspect.currentframe())))

CONFIGS_DIR=os.path.join(script_dir(), "configs")

def get_configs():
    return {cfg: os.path.join(CONFIGS_DIR,cfg) for cfg in
            os.listdir(CONFIGS_DIR) if not cfg.startswith(('.','_'))}


if __name__ == "__main__":

    def error(msg):
        sys.stderr.write("** {}: {}\n".format(__file__, msg))
        sys.exit(1)

    cmd_list=("list-configs", "config-path", "attach")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cmd", nargs='?',
                        help="command to execute",
                        choices=cmd_list,
                        default="attach")
    parser.add_argument("-c", "--config",
                        help="cscope configuration",
                        default="basic")
    args = parser.parse_args()

    # Run the specified command:
    if args.cmd == "list-configs":
        for key in get_configs().keys():
            print "  {}".format(key)
    elif args.cmd == 'config-path':
        path = get_configs().get(args.config)
        if path:
            print path
        else:
            error("configuration '{}' does not exist".format(args.config))
