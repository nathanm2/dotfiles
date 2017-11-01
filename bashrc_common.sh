
#
# Common Aliases
#
alias g=gvim


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#
# Add cscope_db to your path:
#
cscope_db_path=${DIR}/cscope_db
if [[ ":$PATH:" != *":${cscope_db_path}:"* ]]; then
    export PATH=$PATH:${cscope_db_path}
fi
source ${DIR}/cscope_db/cscope_db_completion
source ${DIR}/cscope_db/cscope_db_bash.sh

# Alter the prompt if we're inside a Docker image:
if [ -n "${DOCKER_IMAGE}" ] && [ -z "${debian_chroot:-}" ]; then
    debian_chroot=${DOCKER_IMAGE##*/}
fi

#
# Enable the git prompt
#
# PROMPT_COMMAND: Is called every time the prompt needs to be displayed.
#   __git_ps1            : Takes two strings (prefix and suffix) and formulates
#                          a PS1 value by displaying the current git branch
#                          between them.
#   \[\33]0;...\007\]    : Sets the terminal title.
#   \[\033[1;33m\]       : Changes the text color to yellow.
#   ${debian_chroot:...} : Displays the current container.
#   \[\033[1;32m\]       : Changes the text color to green.
#   \u@\h                : Displays the user and host.
#   \[\033[0m\]          : Resets the color scheme.
#   \w                   : Displays the current working directory.
#   $                    : Displays the dollor sign.
#
source ${DIR}/git-prompt.sh
PROMPT_COMMAND='__git_ps1 "\[\033]0;\u@\h: \w " "\a\]\[\033[1;33m\]${debian_chroot:+($debian_chroot)}\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "'
