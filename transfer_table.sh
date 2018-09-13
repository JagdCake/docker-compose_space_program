#!/bin/bash

# exit script on any error
set -e

dump_table() {
    echo -e "Dump table for transfer to docker container\n"

    read -p "Table: (table name) " table_name
    read -p "From: (database name) " from_db_name
    read -e -p "To: (path (absolute) to save dump file in) " path_to_dump

    pg_dump -t "$table_name" "$from_db_name" > "$path_to_dump"/dump
}

transfer_table() {
    echo -e "Transfer table to docker container\n"

    read -e -p "App: (path to dockerized app) " app_dir
    read -p "Container: (container name) " container_name
    read -p "Container database: (container database name) " container_database

    cd "$app_dir"

    docker.compose build || docker-compose build
    docker.compose up -d || docker-compose up -d

    docker cp "$path_to_dump"/dump "$container_name":/home/
    docker exec -it "$container_name" sh -c "psql -h localhost -U "${container_database}" < /home/dump"
    docker exec -it "$container_name" rm /home/dump

    rm "$path_to_dump"/dump

    docker.compose down || docker-compose down
}

