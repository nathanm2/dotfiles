
#
# Common Aliases
#
alias g=gvim


#
# Enable the git prompt
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/git-prompt.sh
PROMPT_COMMAND='__git_ps1 "\[\033]0;\u@\h: \w " "\007\]\u@\h:\w\$ "'
