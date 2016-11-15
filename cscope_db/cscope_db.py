#! /usr/bin/env python

"""
A utility for managing Cscope databases.
"""

import argparse
import sys
import os
import inspect
import ConfigParser
import json
import errno
import datetime

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
    configdir = os.path.dirname(configname)

    config.add_section('config')
    generators = os.path.join(script_dir(), "generators")
    config.set('config', 'generators', generators)
    config.set('config', 'default', 'basic')
    config.set('config', 'dbfile', os.path.join(configdir, "db.json"))

    ensure_dir(configdir)
    with open(configname, 'wb') as configfile:
        config.write(configfile)

def read_db(config):
    """ Read the database from disk. """
    dbname = config.get('config', 'dbfile')
    try:
        dbfile = open(dbname, 'r')
        return json.load(dbfile)
    except IOError as err:
        if err.errno != errno.ENOENT:
            raise
    return {}

def write_db(config, db):
    """ Write the database to disk. """
    dbname = config.get('config', 'dbfile')
    dbdir = os.path.dirname(dbname)
    ensure_dir(dbdir)

    # Write to a temporary file and then switch things atomically:
    tmp = os.path.join(dbdir, '.'+os.path.basename(dbname))
    with open(tmp, 'wb') as tmpfile:
        json.dump(db, tmpfile, indent=2)
        tmpfile.flush()
        os.fsync(tmpfile.fileno())
    os.rename(tmp, dbname)

def error(msg):
    sys.stderr.write("** {}: {}\n".format(NAME, msg))

def get_generators(config):
    gendir = config.get('config', 'generators')
    return {cfg: os.path.join(gendir,cfg) for cfg in
            os.listdir(gendir) if not cfg.startswith(('.','_'))}

def generator_path(config, args):
    gens = get_generators(config)
    generator = args.generator
    if gens.has_key(generator):
        return gens[generator]
    else:
        return None


def list_op(config, args):
    gens = get_generators(config)
    if args.generator:
        gens = {k:v for k,v in gens.iteritems() if args.generator == k}
        if not gens:
            error("No such generator: {}".format(args.generator))
            return 1

    print("Generators:")
    for name,path in gens.items():
        print("  {0:15}  {1}".format(name, path))
    return 0

def init_op(config, args):
    generators = get_generators(config)
    generator = args.generator

    # Find the appropriate generator script:
    if generators.has_key(generator):
        genpath = generators[generator]
    else:
        error("No such generator: {}".format(generator))
        return 1

    # Run the generator:
    os.system("{} {} {}".format(genpath, args.root, args.output))

    # Update the database:
    db = read_db(config)
    entry = {'output': args.output,
             'generator': args.generator,
             'updated': '{:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now())
             }
    if args.name:
        entry['name'] = args.name
    db[args.root] = entry
    write_db(config, db)

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

    default_gen = config.get("config", "default")

    # Create sub-parsers to process the remaining commands:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", "-c",
            help="{}'s configuration file.  Default: {}".\
                    format(NAME, default_config),
            default=default_config)

    subparsers = parser.add_subparsers(
            title="Subcommands",
            metavar="")

    # List Sub-command:
    list_parser = subparsers.add_parser('list',
            help="List generators and projects.")
    list_parser.add_argument("generator", nargs='?')
    list_parser.set_defaults(func=list_op)

    # Init Sub-command:
    init_parser = subparsers.add_parser('init',
            help="Initialize a project.")
    init_parser.add_argument("--name", "-n",
            help="Optional name of the project")
    init_parser.add_argument("-r", "--root",
            help="The root of the source tree. Default: CWD",
            default=os.getcwd())
    init_parser.add_argument("-o", "--output",
            help="Where to store the output. Default: CWD/.cscope",
            default=os.path.join(os.getcwd(), '.cscope'))
    init_parser.add_argument("generator", nargs='?', default=default_gen)
    init_parser.set_defaults(func=init_op)

    args = parser.parse_args(args)

    # Invoke the appropriate sub-operation:
    args.func(config, args)
