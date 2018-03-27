#!/bin/bash

# set the app name from the first script argument
app_name=$1

# enter path to production dir as the second script argument
dir=$2

if [[ $# -ne 2 ]]; then
    echo "Usage: ./transferFiles.sh [APP NAME] [PRODUCTION DIR PATH]"
    exit
fi

dir_check="`ls $dir | grep -io docker-compose.yml`"

if [[ $dir_check == '' ]]; then
    echo "Wrong directory, docker-compose.yml not found."
    exit
fi

cd $dir

# folder / file to exclude from archiving
exclude=data

# archive everything that is not hidden and not excluded
start=`date +%s`
tar --exclude=$exclude -cvzf $app_name.tar.gz *
end=`date +%s`
creation_time=$((end-start))

echo -e "\nArchive created in $creation_time sec.\n"

# if the VPS username is different than the local one create an environment variable 
user=`whoami`

destination="Containers/$app_name/"

# use an environment variable for the server IP address
ssh $user@$VPSIP mkdir -p $destination'logs'

scp $app_name.tar.gz $user@$VPSIP:$destination

echo

rm $app_name.tar.gz

start=`date +%s`
# extract the archive in the app dir
ssh $user@$VPSIP tar -xvzf $destination"$app_name".tar.gz -C $destination
end=`date +%s`
extract_time=$((end-start))

echo -e "\nArchive extracted in $extract_time sec.\n"

ssh $user@$VPSIP rm $destination"$app_name".tar.gz

echo -e "Done\n"
