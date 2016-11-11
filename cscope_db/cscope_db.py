#! /usr/bin/env python

"""
A utility for managing Cscope databases.
"""

import argparse
import sys
import os
import inspect

def script_dir():
    """ Return the directory path containing this script."""
    return os.path.dirname(os.path.abspath(inspect.getfile(
        inspect.currentframe())))

CONFIGS_DIR=os.path.join(script_dir(), "generators")

def error(msg):
    sys.stderr.write("** {}: {}\n".format(os.path.basename(__file__), msg))

def get_generators():
    return {cfg: os.path.join(CONFIGS_DIR,cfg) for cfg in
            os.listdir(CONFIGS_DIR) if not cfg.startswith(('.','_'))}

def list_generators(args):
    g = get_generators()
    if args.generators:
        try:
            g = {name:g[name] for name in args.generators}
        except KeyError as err:
            error("generator {} not found".format(err))
            sys.exit(1)

    for name,path in g.items():
        print("  {0:15}  {1}".format(name, path))

# TODO: Take this from the config file:
DEFAULT_GENERATOR = "basic"

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", "-c",
            help="cscope_db configuration file (Default: %(default)s).",
            default=os.path.join(os.path.expanduser("~"),".cscope_db"))
    parser.set_defaults(func=None)

    subparsers = parser.add_subparsers(
            title="Subcommands",
            metavar="")

    gen_parser = subparsers.add_parser('list-generators',
            help="List available Cscope generator scripts.")
    gen_parser.add_argument("generators", nargs='*',
            help="Generator name(s)")
    gen_parser.set_defaults(func=list_generators)

    args = parser.parse_args()

    if args.func:
        args.func(args)
    else:
        parser.print_help()
