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

dependency_check() {
    if [ $(which fzf 2>/dev/null) ]; then
        dependency=true
    fi
}

select_files() {
    dependency_check

    from_tag_msg='Archive all files changed AFTER a specific tagged commit'
    from_tag_prmt='From tag: '
    to_tag_msg='To a specific tagged commit (INCLUDING)'
    to_tag_prmt='To tag: '

    if [ "$dependency" == true ]; then
        from_tag="$(git tag | fzf --header="$from_tag_msg" --prompt="$from_tag_prmt")"
        if [ "$(git tag | wc -l)" -gt 1 ]; then
            to_tag="$(git tag | fzf --header="$to_tag_msg" --query='Cancel selection to include ALL files changed since' --prompt="$to_tag_prmt")"
        fi
    else
        echo "$first_tag_msg"
        read -p "$from_tag_prmt" from_tag
        if [ "$(git tag | wc -l)" -gt 1 ]; then
            echo "$to_tag_msg"
            echo "Leave blank to include ALL files changed since"
            read -p "$to_tag_prmt" to_tag
        fi
    fi

    mapfile -t updated_files < <(git log --pretty=format: --name-only "$from_tag".."$to_tag" | sort | uniq)
}

# check if any gitignored files have been modified after the selected commit
check_for_ignored_modified_files() {
    # don't do anything if there is no .gitignore file
    if [ ! -f .gitignore ]; then
        return
    fi

    # get the date (only, not the whole timestamp) of the selected tagged commit
    from_tag_date="$(git show -s --format=%ci "$from_tag" | tail -n 1 | awk '{ print $1 }')" # YEAR-MM-DD
    # convert string date into integer
    # Source: https://unix.stackexchange.com/questions/84381/how-to-compare-two-dates-in-a-shell/170982#170982
    from_tag_date=$(date -d $(echo "$from_tag_date") +%s)

    if [ ! -z "$to_tag" ]; then
        to_tag_date="$(git show -s --format=%ci "$to_tag" | tail -n 1 | awk '{ print $1 }')"
        to_tag_date=$(date -d $(echo "$to_tag_date") +%s)
    fi

    files_modified=false

    while read -r file; do
        # make sure to check only for gitignored files, not directories
        if [ -f "$file" ]; then
            # show the last modification time of a file / folder
            last_mod_date=$(date +%F -r "$file") # YEAR-MM-DD
            last_mod_date=$(date -d $(echo "$last_mod_date") +%s)

            if [[ "$last_mod_date" -gt "$from_tag_date" && -z "$to_tag_date" ]]; then
                echo ""$file" has been modified"
                files_modified=true
            elif [[ ! -z "$to_tag_date" && "$to_tag_date" -gt "$last_mod_date" && "$last_mod_date" -gt "$from_tag_date" ]]; then
                echo ""$file" has been modified"
                files_modified=true
            fi
        fi
    done < .gitignore

    if [ "$files_modified" = true ]; then
        echo -e "\nSelect gitignored files to transfer"
        read -e -p "Filename(s): (space separated) " -a files_to_add

        # add the selected files to the already created tar
    fi
}

compress_files() {
    project_check
    cd "$project_path"

    git checkout production

    if [ "$mode" == 'all' ]; then
        # archive everything that is not hidden and not excluded
        tar $(echo "${files_to_exclude[@]/#/--exclude=}") -cvf "$project_name".tar *
    elif [ "$mode" == 'specific' ]; then
        select_files
        tar -cvf "$project_name".tar $(echo "${updated_files[@]}")
    fi

    bzip2 "$project_name".tar

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

    scp "$project_name".tar.bz2 "$username"@"$ip_address":"$destination"/"$project_name"
}

decompress_files() {
    # extract the archive in the project directory
    ssh "$username"@"$ip_address" tar -xvjf "$destination"/"$project_name"/"$project_name".tar.bz2 -C "$destination"/"$project_name"

    echo -e "\nArchive extracted in "$destination"/"$project_name"/ sec.\n"

    if [ "$mode" == 'specific' ]; then
        docker-compose down || docker.compose down && docker-compose build || docker.compose build && docker-compose up -d || docker.compose up -d &&
        echo -e ""$project_name" container restarted successfully.\n"
    fi
}

clean_up() {
    echo -e "Performing cleanup\n"

    rm "$project_name".tar.bz2
    ssh "$username"@"$ip_address" rm "$destination"/"$project_name"/"$project_name".tar.bz2

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

