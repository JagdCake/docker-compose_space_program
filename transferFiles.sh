#!/bin/bash

# enter path to production dir as the first script argument
dir=$1
cd $dir

app_name=3d

# folder / file to exclude from archiving
exclude=data

# archive everything that is not hidden and not excluded
tar --exclude=$exclude -cvzf $app_name.tar.gz *