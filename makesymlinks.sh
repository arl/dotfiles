#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles-bak             # old dotfiles backup directory

# list of files/folders to symlink in homedir
# TODO: when the list will start to grow, too much, create the list on the fly by taking everthing under dotfiles dir, excluding repo files
files="bash_aliases bashrc gitconfig profile machine_specific pylintrc screenrc vimrc tmux.conf tmux-git fonts/* vim/colors/*.vim vim/ftdetect/go.vim vim/syntax/go.vim" 
##########

# create $olddir in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# move any existing dotfiles in homedir to $olddir directory,
# check that destination directories exist, or create them
# then create symlinks from the homedir to any files in
# the ~/dotfiles directory specified in $files
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file $olddir/

    # check that destination directory exists
    dstdir=$(dirname ~/.$file)
    if [ ! -d $dstdir ]; then
        echo $dstdir doesn\'t exist, create it
        mkdir -p "${dstdir}"
    fi

    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done

