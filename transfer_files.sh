#!/bin/bash

# set the app name from the first script argument
app_name="$1"

# enter path to production dir as the second script argument
dir="$2"

if [[ $# -ne 2 ]]; then
    echo "Usage: ./transfer_files.sh [APP NAME] [PRODUCTION DIR PATH]"
    exit
fi

dir_check="$(ls "$dir" | grep -io docker-compose.)"

red="$(tput setaf 1)"
reset_color="$(tput sgr0)"

if [[ "$dir_check" == '' ]]; then
    echo -e "Wrong directory, docker-compose.y(a)ml ${red}not found${reset_color}!"
    exit
fi

cd "$dir"

git checkout production

# folder / file to exclude from archiving
exclude_one=docker_volumes/data
exclude_two=node_modules

# archive everything that is not hidden and not excluded
start="$(date +%s)"
tar --exclude="$exclude_one" --exclude="$exclude_two" -cvzf "$app_name".tar.gz *
end="$(date +%s)"
creation_time=$((end-start))

echo -e "\nArchive created in "$creation_time" sec.\n"

read -p "Enter server username: " user
read -p "Enter server IP address: " VPS_IP

destination="Containers/"$app_name"/"

ssh "$user"@"$VPS_IP" mkdir "$destination" &&

scp "$app_name".tar.gz "$user"@"$VPS_IP":"$destination"

echo

rm "$app_name".tar.gz

start="$(date +%s)"
# extract the archive in the app dir
ssh "$user"@"$VPS_IP" tar -xvzf "$destination""$app_name".tar.gz -C "$destination"
end="$(date +%s)"
extract_time=$((end-start))

echo -e "\nArchive extracted in "$extract_time" sec.\n"

ssh "$user"@"$VPS_IP" rm "$destination""$app_name".tar.gz

echo -e "Done\n"

cd ~- 

