
#
# Common Aliases
#
alias g=gvim


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#
# Add cscope_mngr to your path
#
cscope_db_path=${DIR}/cscope_db
if [[ ":$PATH:" != *":${cscope_db_path}:"* ]]; then
    export PATH=$PATH:${cscope_db_path}
fi

#
# Enable the git prompt
#
source ${DIR}/git-prompt.sh
PROMPT_COMMAND='__git_ps1 "\[\033]0;\u@\h: \w " "\007\]\u@\h:\w\$ "'
