#!/bin/bash

# set the app name from the first script argument
app_name=$1

# enter path to production dir as the second script argument
dir=$2
cd $dir

# folder / file to exclude from archiving
exclude=data

# archive everything that is not hidden and not excluded
tar --exclude=$exclude -cvzf $app_name.tar.gz *

# if the VPS username is different than the local one create an environment variable 
user=`whoami`

destination="Containers/$app_name/"

# use an environment variable for the server IP address
ssh $user@$VPSIP mkdir -p $destination'logs'

scp $app_name.tar.gz $user@$VPSIP:$destination

rm $app_name.tar.gz

# extract the archive in the app dir
ssh $user@$VPSIP tar -xvzf $destination"$app_name".tar.gz -C $destination

ssh $user@$VPSIP rm $destination"$app_name".tar.gz