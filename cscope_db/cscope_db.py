#! /usr/bin/env python

"""
A utility for managing Cscope databases.
"""

import argparse
import sys
import os
import stat
import inspect
import ConfigParser
import json
import errno
import datetime


# Module Exceptions:
class Error(Exception):
    """ Base class for exceptions in this module."""
    pass

class ProjectError(Error):
    """ Project related error. """
    def __init__(self, msg):
        self.message = msg

class ProjectNameError(ProjectError):
    """ Exception raised when a project cannot be found by name """
    def __init__(self, projectname):
        msg = "No project found in database: {}".format(projectname)
        super().__init__(msg)

class GeneratorError(Error):
    """ Generator related error. """
    def __init__(self, generator):
        self.message = "No generator found: {}".format(generator)

# Utilities:

NAME= os.path.basename(__file__)

def error(msg):
    """ Display an error message to the standard error stream. """
    sys.stderr.write("** {}: {}\n".format(NAME, msg))

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
    """ Create a program 'config' file with suitable defaults: """
    config = ConfigParser.RawConfigParser()
    configdir = os.path.dirname(configname)

    config.add_section('config')
    generators = os.path.join(script_dir(), "generators")
    config.set('config', 'generators', generators)
    config.set('config', 'default', 'basic')
    config.set('config', 'dbfile', os.path.join(configdir, "db.json"))
    config.set('config', 'runname', 'cs_runner.sh')

    ensure_dir(configdir)
    with open(configname, 'wb') as configfile:
        config.write(configfile)

def read_db(config):
    """ Read the database from storage. """
    dbname = config.get('config', 'dbfile')
    try:
        dbfile = open(dbname, 'r')
        return json.load(dbfile)
    except IOError as err:
        if err.errno != errno.ENOENT:
            raise
    return {}

def write_db(config, db):
    """ Write the database to storage. """
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


def get_generators(config):
    """ Get a dict of {'generator name' => 'generator path'} """
    gendir = config.get('config', 'generators')
    return {cfg: os.path.join(gendir,cfg) for cfg in
            os.listdir(gendir) if not cfg.startswith(('.','_'))}

def make_project_name(db, root):
    """ Generate a unique project name based on the source root path. """
    (head, base) = os.path.split(root)
    suffix = ""
    idx = 0
    while True:
        name = "{}{}".format(base, suffix)
        if name not in db.keys():
            return name
        idx += 1
        suffix = str(idx)

def find_project_by_dir(db, dir=os.getcwd()):
    """ Find the closest matching project by directory."""
    result_len = 0
    result = None
    dir_len = len(dir)

    for project in db.values():
        root = project['root']
        root_len = len(root)
        if root_len <= dir_len and dir.startswith(root):
            if root_len > result_len:
                result = project
                result_len = root_len

    if not result:
        msg = "No parent project found for directory: {}".format(dir)
        raise ProjectError(msg)

    return result

def find_project(db, projectname=None):
    if projectname:
        try:
            return db[projectname]
        except KeyError:
            raise ProjectNameError(projectname)
    else:
        return find_project_by_dir(db)


def list_op(config, args):
    gens = get_generators(config)
    if args.generator:
        gens = {k:v for k,v in gens.iteritems() if args.generator == k}
        if not gens:
            raise GeneratorError(args.generator)

    print("Generators:")
    for name,path in gens.items():
        print("  {0:15}  {1}".format(name, path))

    print("\nProjects:")
    db = read_db(config)
    for name,entry in db.items():
        print("  {0:15}  {1:15} {2}".format(name,
            entry["generator"],
            entry["updated"]))
        print("      Root: {0}".format(entry["root"]))
        print("    Output: {0}\n".format(entry["output"]))
    return 0

def build_generator_script(genpath, name, root, output):
    script = os.path.join(output, name)

    ensure_dir(output)
    with open(script, 'wb') as sf:
        sf.write("#!/bin/sh\n")
        sf.write("{0} {1} {2}".format(genpath, root, output))
    os.chmod(script, os.stat(script).st_mode | stat.S_IEXEC)
    return script

def init_op(config, args):
    db = read_db(config)

    # Find the appropriate generator script:
    generators = get_generators(config)
    generator = args.generator
    if generators.has_key(generator):
        genpath = generators[generator]
    else:
        raise GeneratorError(generator)

    # Cleanup any old projects with the same output directory.
    # Check for project name conflicts at the same time.
    output = os.path.normpath(args.output)
    for project in db.values():
        projectname = project['name']
        if output == project['output']:
            rm_project_files(project)
            del db[projectname]
        elif args.name == projectname:
            msg = "Project name already in use: {}".format(projectname)
            raise ProjectError(msg)

    # Build a shell script for invoking the generator:
    runner = build_generator_script(genpath, args.runname, args.root, output)

    # Run the generator script:
    os.system(runner)

    # Create a unique project name if not provided by the caller:
    name = args.name or make_project_name(db, args.root)

    # Update the database:
    project = {'name': name,
               'output': output,
               'generator': generator,
               'root': args.root,
               'runner': runner,
               'updated':'{:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now())
              }
    db[name] = project

    # Write the database:
    write_db(config, db)

def rm_project_files(project):
    """
    Cleans all the project files and project directory.

    Note: It does not remove the project from the database.
    """
    outputdir = project['output']
    try:
        for filename in os.listdir(outputdir):
            os.remove(os.path.join(outputdir, filename))
        if os.path.isdir(outputdir):
            os.removedirs(outputdir)
    except OSError: pass

def clear_op(config, args):
    db = read_db(config)
    project = find_project(db, args.name)
    rm_project_files(project)
    del db[project['name']]
    write_db(config, db)

def find_op(config, args):
    db = read_db(config)
    project = find_project_by_dir(db)
    print("{0} {1}".format(project['name'], project['output']))

def run_op(config, args):
    db = read_db(config)
    project = find_project(db, args.name)
    os.system(project['runner'])
    project['updated'] = '{:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now())
    write_db(config, db)

def main():
    # The path to the default cscope_db config file:
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
    list_parser.add_argument("--generator", "-g",
            help="Filter by generator")
    list_parser.add_argument("names",
            help="Project names.", nargs='*')
    list_parser.set_defaults(func=list_op)

    # Init Sub-command:
    init_parser = subparsers.add_parser('init',
            help="Initialize a project.")
    init_parser.add_argument("-r", "--root",
            help="The root of the source tree. Default: CWD",
            default=os.getcwd())
    init_parser.add_argument("-o", "--output",
            help="Where to store the output. Default: CWD/.cscope",
            default=os.path.join(os.getcwd(), '.cscope'))
    init_parser.add_argument("-g", "--generator",
            help="Cscope generator to use.  Default: " + default_gen,
            default=default_gen)
    runname = config.get("config", "runname")
    init_parser.add_argument("-n", "--runname",
            help="The name of runner script.  Default: " + runname,
            default=runname)
    init_parser.add_argument("name",
            help="Project name.", nargs='?')
    init_parser.set_defaults(func=init_op)

    # Clear Sub-command:
    clear_parser = subparsers.add_parser('clear',
            help="Remove a project's cscope files.")
    clear_parser.add_argument("name",
            help="Project name.", nargs='?')
    clear_parser.set_defaults(func=clear_op)

    # Find Sub-command:
    clear_parser = subparsers.add_parser('find',
            help="Find the closest project from the current working directory.")
    clear_parser.set_defaults(func=find_op)

    # Refresh the cscope information:
    run_parser = subparsers.add_parser('run',
            help="Re-run the cscope generator.")
    run_parser.add_argument("name",
            help="Project name.", nargs='?')
    run_parser.set_defaults(func=run_op)

    # Parse the arguments:
    args = parser.parse_args(args)

    # Invoke the appropriate sub-operation:
    try:
        args.func(config, args)
        return 0
    except Error as e:
        error(e.message)
        return 1

if __name__ == "__main__":
    main()

