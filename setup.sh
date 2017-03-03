#!/bin/bash

# Make a backup of the original directory/file:
backup ()
{
	old=$1
	if [ -e "$old" ]; then
		shopt -s nullglob
		tmp=(${old}*)
		shopt -u nullglob
		( set -x; mv ${old} ${old}.bk.${#tmp[@]} )
	fi
}

mk_link ()
{
	new=$1
	old=$2
	# Test if NEW exists and NEW and OLD point to different things.
	if [ -e "$new" ] && [ ! "$new" -ef "$old" ]; then
		backup $old
		( set -x; ln -s $new $old)
	fi
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#-- Vim Setup --------------------------------------------------------
vim_version=$(vim --version | head -1 | cut -d ' ' -f 5)

mk_link ${DIR}/vim ${HOME}/.vim

## Vim 7.4 allows the rc file to located within the .vim directory.
##
## We make use of this feature if it's supported by moving any existing .vimrc
## to a backup file.
if [ $(bc <<< "${vim_version} < 7.4") = 1 ]; then
	mk_link ${DIR}/vimrc ${HOME}/.vimrc
else
	backup ${HOME}/.vimrc
fi

## Install Vundle (Vim's package manager):
if [ ! -d ${DIR}/vim/bundle/Vundle.vim ]; then
	git clone https://github.com/VundleVim/Vundle.vim.git \
		${DIR}/vim/bundle/Vundle.vim
fi

## Install Vim bundles:
vim +BundleInstall +qall

#-- Bash Setup ---------------------------------------------------------
mk_link ${DIR}/inputrc ${HOME}/.inputrc

if [ -e ${HOME}/.bashrc ] && ! grep -q bashrc_common.sh ${HOME}/.bashrc; then
	printf "\n#Commonly used aliases and commands\n" >> ${HOME}/.bashrc
	printf "source ${DIR}/bashrc_common.sh\n" >> ${HOME}/.bashrc
fi

#-- Git/Ctags ----------------------------------------------------------

# Rebuild ctags and cscope every time a git repo is modified via a checkout,
# merge, rebase or commit.
#
if ! git config --global init.templatedir >/dev/null; then
	git config --global init.templatedir ${DIR}/git_template
	git config --global alias.ctags '!.git/hooks/ctags'
	git config --global alias.ctags-enable '!.git/hooks/ctags-enable'
	git config --global alias.ctags-disable '!.git/hooks/ctags-disable'
    git config --global alias.cscope '!.git/hooks/cscope'
fi

# Add the 'rclean' alias to recursively clean a repo:
git config --global alias.rclean '!git clean -fdx && git submodule foreach git clean -fdx'

# Add the 'su' alias to do a submodule update:
git config --global alias.su 'submodule update'

# Enable 'Reuse Recorded Resolution' globally:
git config --global rerere.enabled true

# Get sub-module status in `git status`:
git config --global status.submoduleSummary true

# Git diff to show a bit more details for submodules:
git config --global diff.submodule log
