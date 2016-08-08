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
	if [ -e "$new" ] && [ ! "$new" -ef "$old" ]; then
		backup $old
		( set -x; ln -s $new $old)
	fi
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#-- Vim Setup --------------------------------------------------------
backup ${HOME}/.vimrc
mk_link ${DIR}/vim ${HOME}/.vim

## Install Vundle (Vim's package manager):
if [ ! -d ${DIR}/vim/bundle/Vundle.vim ]; then
	git clone https://github.com/VundleVim/Vundle.vim.git \
		${DIR}/vim/bundle/Vundle.vim
fi

## Install Vim bundles:
vim +BundleInstall +qall

#-- Bash Setup ---------------------------------------------------------
mk_link ${DIR}/inputrc ${HOME}/.inputrc
