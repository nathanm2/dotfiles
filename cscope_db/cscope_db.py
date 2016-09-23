#! /usr/bin/env python3

"""
A utility for managing Cscope databases.
"""

import argparse
import sys
import os
import inspect

def script_dir():
    """ Get the path of THIS script."""
    return os.path.dirname(os.path.abspath(inspect.getfile(
        inspect.currentframe())))

CONFIGS_DIR=os.path.join(script_dir(), "generators")

def error(msg):
    sys.stderr.write("** {}: {}\n".format(__file__, msg))

def generators():
    return {cfg: os.path.join(CONFIGS_DIR,cfg) for cfg in
            os.listdir(CONFIGS_DIR) if not cfg.startswith(('.','_'))}

def list_generators(args):
    for key in generators().keys():
        print("  {}".format(key))

def generator_path(args):
    path = generators().get(args.generator)
    if path:
        print(path)
    else:
        error("generator '{}' does not exist".format(args.generator))
        sys.exit(1)

# TODO: Take this from the config file:
DEFAULT_GENERATOR = "basic"

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", "-c",
            help="cscope_db configuration file (Default: %(default)s).",
            default=os.path.join(os.path.expanduser("~"),".cscope_db"))
    parser.set_defaults(func=None)

    subparsers = parser.add_subparsers(
            title="subcommands",
            metavar="")

    lg_parser = subparsers.add_parser('list-generators', aliases=['lg'],
            help="List available Cscope database generator scripts.")
    lg_parser.set_defaults(func=list_generators)

    gp_parser = subparsers.add_parser('generator-path', aliases=['gp'],
            help="Display the path to a Cscope generator script.")
    gp_parser.set_defaults(func=generator_path)

    # Add the generator argument to the following sub-commands:
    for p in [gp_parser]:
        p.add_argument("generator", nargs='?',
                help= "The cscope generator script (Default: %(default)s)",
                default=DEFAULT_GENERATOR)

    args = parser.parse_args()

    if args.func:
        args.func(args)
    else:
        parser.print_help()
