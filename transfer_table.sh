#!/bin/bash

# exit script on any error
set -e

environment="$1"

dump_table() {
    echo -e "Dump table(s) for transfer to docker container\n"

    read -p "Table(s): (table name(s) space separated) " -a table_names
    read -p "From: (database name) " from_db_name
    read -e -p "To: (path (absolute) to save dump file in) " path_to_dump

    pg_dump -O $(echo "${table_names[@]/#/-t }") "$from_db_name" > "$path_to_dump"/dump
}

transfer_table() {
    echo -e "Transfer table to docker container\n"

    read -e -p "App: (path to dockerized app) " app_dir
    read -p "Container: (container name) " container_name
    read -p "Container database: (container database name) " container_database

    cd "$app_dir"

    docker.compose build || docker-compose build
    docker.compose up -d || docker-compose up -d

    # allow time for the database to start
    sleep 3

    docker cp "$path_to_dump"/dump "$container_name":/home/
    docker exec -it "$container_name" sh -c "psql -h localhost -U "${container_database}" < /home/dump"
    docker exec -it "$container_name" rm /home/dump

    rm "$path_to_dump"/dump

    docker.compose down || docker-compose down
}

transfer_dump() {
    echo -e "Copy table dump to production server\n"

    read -p "User: (server username) " username
    read -p "IP: (server IP address) " ip_address
    read -e -p "To: (path (absolute) to paste dump file in) " server_path_to_dump

    scp "$path_to_dump"/dump "$username"@"$ip_address":"$server_path_to_dump"
    rm "$path_to_dump"/dump
    scp ./transfer_table.sh "$username"@"$ip_address":"$server_path_to_dump"

    echo -e "Now, run - ./transfer_table.sh prod\n"
    # Source: https://stackoverflow.com/questions/626533/how-can-i-ssh-directly-to-a-particular-directory/626574#626574
    ssh -t "$username"@"$ip_address" "cd "$server_path_to_dump"; bash"
}

check_for_dump() {
    echo -e "Do you have a database dump?\n"
    select choice in "Yes" "No" "Cancel"; do
        case "$choice" in
            "Yes" )
                read -e -p "Dump: (path to dump directory) " path_to_dump

                if [ ! -d "$path_to_dump" ]; then
                    echo ""$path_to_dump" is not a directory"
                    check_for_dump
                fi

                break;;
            "No" )
                dump_table
                break;;
            "Cancel" )
                exit;;
        esac
    done
}

if [ "$environment" == 'dev' ]; then
    check_for_dump
    transfer_table
elif [ "$environment" == 'stag' ]; then
    check_for_dump
    transfer_dump
elif [ "$environment" == 'prod' ]; then
    path_to_dump="$(pwd)"
    transfer_table
    echo -e "Transfer successful\n"
    echo "You can delete "$path_to_dump"/transfer_table.sh"
else
    echo 'Usage: ./transfer_table.sh dev OR stag OR prod (but only when prompted)'
    exit
fi

