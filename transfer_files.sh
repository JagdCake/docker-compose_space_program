#!/bin/bash

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

select_files() {
    echo "Archive all files changed AFTER a specific tagged commit"
    read -p "From tag: " from_tag
    echo "To a specific tagged commit (INCLUDING)"
    echo "Leave blank to include ALL files changed since"
    read -p "To tag: " to_tag

    mapfile -t updated_files < <(git log --pretty=format: --name-only "$from_tag".."$to_tag" | sort | uniq)
}

compress_files() {
    project_check
    cd "$project_path"

    git checkout production

    if [ "$mode" == 'all' ]; then
        # archive everything that is not hidden and not excluded
        tar $(echo "${files_to_exclude[@]/#/--exclude=}") -cvzf "$project_name".tar.gz *
    elif [ "$mode" == 'specific' ]; then
        select_files
        tar -cvzf "$project_name".tar.gz $(echo "${updated_files[@]}")
    fi

    echo -e "\nArchive created and ready for transfer.\n"
}

transfer_archive() {
    echo -e "Transfer archived files to server\n"

    echo "Enter server username"
    read -p "Username: " username
    echo "Enter server IP address"
    read -p "IP: " ip_address

    if [ "$mode" == 'all' ]; then
        echo "Enter absolute path to directory you want to create the project in"
        read -p "Destination: " destination
        ssh "$username"@"$ip_address" mkdir "$destination"/"$project_name"
    elif [ "$mode" == 'specific' ]; then
        echo "Enter absolute path to the directory where the project folder is"
        read -p "Destination: " destination
    fi

    scp "$project_name".tar.gz "$username"@"$ip_address":"$destination"/"$project_name"
}

decompress_files() {
    # extract the archive in the project directory
    ssh "$username"@"$ip_address" tar -xvzf "$destination"/"$project_name"/"$project_name".tar.gz -C "$destination"/"$project_name"

    echo -e "\nArchive extracted in "$destination"/"$project_name"/ sec.\n"

    if [ "$mode" == 'specific' ]; then
        docker-compose down || docker.compose down && docker-compose build || docker.compose build && docker-compose up -d || docker.compose up -d &&
        echo -e ""$project_name" container restarted successfully.\n"
    fi
}

clean_up() {
    echo -e "Performing cleanup\n"

    rm "$project_name".tar.gz
    ssh "$username"@"$ip_address" rm "$destination"/"$project_name"/"$project_name".tar.gz

    echo -e "All done.\n"

    cd ~-
}

select choice in "Transfer only files changed AFTER the last deployment" "Transfer ALL project files" "Quit"; do
    case "$choice" in
        "Transfer only files changed AFTER the last deployment" )
            mode="specific"
            break;;
        "Transfer ALL project files" )
            mode="all"
            break;;
        "Quit" )
            exit;;
    esac
done

compress_files
transfer_archive
decompress_files
clean_up

