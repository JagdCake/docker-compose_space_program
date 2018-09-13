#!/bin/bash

# exit script on any error
set -e

dump_table() {
    echo -e "Dump table for transfer to docker container\n" 

    read -p "Dump: (table name) " table_name
    read -p "From: (database name) " from_db_name
    read -e -p "To: (path to save dump file in) " path_to_dump

    pg_dump -t "$table_name" "$from_db_name" > "$path_to_dump"/dump
}

