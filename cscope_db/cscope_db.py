#! /usr/bin/env python3

"""
A utility for managing Cscope databases.
"""

import argparse
import sys
import os
import stat
import inspect
from configparser import RawConfigParser
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
        msg = "No project found in database: {0}".format(projectname)
        super().__init__(msg)

class GeneratorError(Error):
    """ Generator related error. """
    def __init__(self, generator):
        self.message = "No generator found: {0}".format(generator)

# Utilities:

NAME= os.path.basename(__file__)

def error(msg):
    """ Display an error message to the standard error stream. """
    sys.stderr.write("** {0}: {1}\n".format(NAME, msg))

def status(msg):
    """ Display a status message to the standard out stream. """
    sys.stdout.write("** {0}: {1}\n".format(NAME, msg))

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
    status("creating config file: {0}.".format(configname))

    configdir = os.path.dirname(configname)
    ensure_dir(configdir)
    config="""# Configuration file for cscope_db.py
[config]
# Directory containing generators.
#
# A generator is a shell script for finding relevant source files and issuing
# the cscope commands to generate the various cscope files.
generators = {generators}

# The default generator.
#
# Used if the user does not specify a generator with the -g switch.
default = basic

# The cscope_db database file.
#
# This is where cscope_db saves information about the various projects.
dbfile = {dbfile}

# The default name of the runner script.
#
# The runner script is generated by cscope_db and contains the parameters to
# run the generator.
runname = cs_runner.sh
""".format(generators=os.path.join(script_dir(), "generators"),
        dbfile=os.path.join(configdir, "db.json"))
    with open(configname, 'w', encoding='utf-8') as f:
        f.write(config)


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
    with open(tmp, 'w', encoding='utf-8') as tmpfile:
        json.dump(db, tmpfile, indent=2)
        tmpfile.flush()
        os.fsync(tmpfile.fileno())
    os.rename(tmp, dbname)


def get_generators(config):
    """ Get a dict of {'generator name' => 'generator path'} """
    gendir = config.get('config', 'generators')
    out = {}
    for cfg in os.listdir(gendir):
        if not cfg.startswith(('.','_')):
            out[cfg] = os.path.join(gendir,cfg)
    return out

def get_genpath(config, generator):
    """ Get the full path to the generator script. """
    try:
        return get_generators(config)[generator]
    except KeyError:
        raise GeneratorError(generator)
    except:
        raise

def unique_project_name(db, root):
    """ Generate a unique project name based on the source root path. """
    (head, base) = os.path.split(root)
    suffix = ""
    idx = 0
    while True:
        name = "{0}{1}".format(base, suffix)
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
        msg = "No parent project found for directory: {0}".format(dir)
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
        _gens = {}
        for k,v in gens.items():
            if args.generator == k:
                _gens[k] = v
        gens = _gens
        if not gens:
            raise GeneratorError(args.generator)

    db = read_db(config)
    _db = {}
    for k,v in db.items():
        if v["generator"] in gens.keys():
            _db[k] = v
    db = _db

    count = 0
    for name,entry in db.items():
        if count == 0:
            print("Projects:")
        else:
            print("")
        count += 1
        print("  {0:15}  {1:15} {2}".format(name,
            entry["generator"],
            entry["updated"]))
        print("      Root: {0}".format(entry["root"]))
        print("    Output: {0}".format(entry["output"]))
    return 0

def list_generators_op(config, args):
    gens = get_generators(config)
    print("Generators:")
    for name, path in gens.items():
        print("  {0:15}  {1}".format(name, path))

def build_generator_script(genpath, name, root, output):
    script = os.path.join(output, name)

    ensure_dir(output)
    with open(script, 'w', encoding='utf-8') as sf:
        sf.write("#!/bin/sh\n")
        sf.write("{0} {1} {2}".format(genpath, root, output))
    os.chmod(script, os.stat(script).st_mode | stat.S_IEXEC)
    return script

def init_op(config, args):
    db = read_db(config)

    # Find the appropriate generator script:
    generator = args.generator
    genpath = get_genpath(config, generator)

    # Cleanup any old projects with the same output directory.
    # Check for project name conflicts at the same time.
    output = os.path.normpath(args.output)
    old_projects = []
    for project in db.values():
        projectname = project['name']
        if output == project['output']:
            status("removing old generator files.")
            rm_project_files(project)
            old_projects.append(projectname)
        elif args.name == projectname:
            msg = "Project name already in use: {0}".format(projectname)
            raise ProjectError(msg)

    for projectname in old_projects:
        del db[projectname]

    # Build a shell script for invoking the generator:
    status("building generator")
    runner = build_generator_script(genpath, args.runname, args.root, output)

    # Run the generator script:
    status("running generator")
    os.system(runner)

    # Create a unique project name if not provided by the caller:
    name = args.name or unique_project_name(db, args.root)

    # Update the database:
    project = {'name': name,
               'output': output,
               'generator': generator,
               'root': args.root,
               'runner': runner,
               'updated':'{0:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now())
              }
    db[name] = project

    # Write the database:
    write_db(config, db)

def rm_project_files(project):
    """
    Cleans all the project files and project directory.

    Note: The project entry is not removed from the database.
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
    status("removing generator files: {0}".format(project["name"]))
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
    runner = project['runner']

    # Reconstruct the runner script if it's missing:
    if not os.path.isfile(runner):
        genpath = get_genpath(config, project['generator'])
        (output, name) = os.path.split(project['runner'])
        status("rebuilding generator")
        build_generator_script(genpath, name, project['root'], output)

    status("running generator: {0}".format(project['name']))
    os.system(project['runner'])
    project['updated'] = '{0:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now())
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
    config = RawConfigParser()
    config.read(configname)

    default_gen = config.get("config", "default")

    # Create sub-parsers to process the remaining commands:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-c", "--config",
            help="{0}'s configuration file.  Default: {1}".\
                    format(NAME, default_config),
            default=default_config)

    subparsers = parser.add_subparsers(
            title="Subcommands",
            metavar="")

    # List Sub-command:
    list_parser = subparsers.add_parser('list',
            help="List projects.")
    list_parser.add_argument("--generator", "-g",
            help="Filter by generator")
    list_parser.add_argument("names",
            help="Project names.", nargs='*')
    list_parser.set_defaults(func=list_op)

    # List Generators Sub-command:
    list_parser = subparsers.add_parser("list-generators",
            help="List generators.")
    list_parser.set_defaults(func=list_generators_op)

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

    if not args:
        args.append("run")

    # Parse the arguments:
    args = parser.parse_args(args)

    # Invoke the appropriate sub-operation:
    try:
        return args.func(config, args)
    except Error as e:
        error(e.message)
        return 1

if __name__ == "__main__":
    sys.exit(main())

