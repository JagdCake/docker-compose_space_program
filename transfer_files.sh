#!/bin/bash

# exit script on any error
set -e

### Options ###
# files / folders to exclude from archiving
files_to_exclude=(docker_volumes/data node_modules)
### ###

project_name="$1"

project_path="$2"

if [[ $# -ne 2 ]]; then
    echo "Usage: ./transfer_files.sh [PROJECT NAME] [PATH TO PROJECT]"
    exit
fi

project_check() {
    red="$(tput setaf 1)"
    reset_color="$(tput sgr0)"

    ls "$project_path"/docker-compose.* > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        echo -e "Wrong directory, docker-compose.y(a)ml ${red}not found${reset_color}!"
        exit
    fi
}

compress_files() {
    project_check
    cd "$project_path"

    git checkout production

    start="$(date +%s)"

    # archive everything that is not hidden and not excluded
    tar $(echo "${files_to_exclude[@]/#/--exclude=}") -cvzf "$project_name".tar.gz *

    end="$(date +%s)"
    compression_time=$((end-start))

    echo -e "\nArchive created in "$compression_time" sec.\n"
}

transfer_archive() {
    echo -e "Transfer archived files to server\n"

    read -p "User: (server username) " username
    read -p "IP: (server IP address) " ip_address
    read -p "Destination: (path (absolute) to create project dir in) " destination

    ssh "$username"@"$ip_address" mkdir "$destination"/"$project_name"

    scp "$project_name".tar.gz "$username"@"$ip_address":"$destination"/"$project_name"
}

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

