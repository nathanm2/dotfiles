#! /usr/bin/env python

"""
A utility for managing Cscope databases.
"""

import argparse
import sys
import os
import inspect
import ConfigParser

NAME= os.path.basename(__file__)

# Utilities:

def script_dir():
    """ Return the directory path containing this script."""
    return os.path.dirname(os.path.abspath(inspect.getfile(
        inspect.currentframe())))

def ensure_dir(dirname):
    """ Ensure that a named directory exists; if not, create it: """
    try:
        os.makedirs(dirname)
    except OSError as err:
        if err.errno != errno.EEXIST:
            raise

def create_config(configname):
    """ Create a 'config' file with defaults: """
    config = ConfigParser.RawConfigParser()

    config.add_section('config')
    generators = os.path.join(script_dir(), "generators")
    config.set('config', 'generators', generators)
    config.set('config', 'default', 'basic')

    ensure_dir(os.path.dirname(configname))
    with open(configname, 'wb') as configfile:
        config.write(configfile)

def error(msg):
    sys.stderr.write("** {}: {}\n".format(NAME, msg))

def get_generators(config):
    gendir = config.get('config', 'generators')
    return {cfg: os.path.join(gendir,cfg) for cfg in
            os.listdir(gendir) if not cfg.startswith(('.','_'))}

def list_op(config, args):
    gens = get_generators(config)

    print("Generators:")
    for name,path in gens.items():
        print("  {0:15}  {1}".format(name, path))


if __name__ == "__main__":

    # The default config file:
    default_config = os.path.join(os.path.expanduser("~"), ".cscope_db",
            "config")

    # Parse the command line args for '-c' first:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--config", "-c", default=default_config)
    (config_arg, args) = parser.parse_known_args()
    configname = config_arg.config

    # If the config file does not exist, create one:
    if not os.path.exists(configname):
        create_config(configname)

    # Parse the config file:
    config = ConfigParser.RawConfigParser()
    config.read(configname)

    # Handle the remaining arguments:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.set_defaults(func=list_op)
    parser.add_argument("--config", "-c",
            help="{}'s configuration file.  Default: {}".\
                    format(NAME, default_config),
            default=default_config)

    subparsers = parser.add_subparsers(
            title="Subcommands",
            metavar="")

    list_parser = subparsers.add_parser('list',
            help="List generators and projects.")
    default_gen = config.get("config", "default")
    list_parser.add_argument("generator", nargs='?')
    list_parser.set_defaults(func=list_op)

    args = parser.parse_args(args)

    # Invoke the appropriate sub-operation:
    args.func(config, args)
