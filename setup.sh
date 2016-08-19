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
