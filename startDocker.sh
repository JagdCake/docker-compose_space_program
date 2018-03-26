#!/bin/bash

# this script works only if it is in the same dir as the Dockerfile / docker-compose.yml

start_up() {
    start=`date +%s`;
    docker.compose build;
    end=`date +%s`;
    build_time=$((end-start));
    echo -e "\nBuild complete in "$build_time" sec!\n";

    start=`date +%s`;
    docker.compose up -d;
    end=`date +%s`;
    up_time=$((end-start));
    echo -e "\nDocker up in "$up_time" sec!\n";

    total=$((build_time+up_time))
}

start_up

# may be needed for the first (local) start up
conf_copy() {
    docker cp ./nginx/nginx.conf nginx:/etc/nginx
    docker exec -it nginx service nginx reload
}

#sleep 10s; conf_copy

# set the app name from the first script argument
app_name=$1

server_err_log=~/Containers/$app_name/logs/err_server
encrypt_err_log=~/Containers/$app_name/logs/err_encrypt
app_err_log=~/Containers/$app_name/logs/err_app
db_err_log=~/Containers/$app_name/logs/err_db

# docker-compose.yml services
services=(nginx encrypt app mongo)

err_check() {
    # '2>&1' makes 'docker logs' output to stdout so 'grep' can be used
    is_server_down="`docker logs "${services[0]}" 2>&1 | grep -io error | tail -n 1`";
    is_encrypt_down="`docker logs "${services[1]}" 2>&1 | grep -io error | tail -n 1`";
    is_app_down="`docker logs "${services[2]}" 2>&1 | grep -io error  | tail -n 1`";
    is_db_down="`docker logs "${services[3]}" 2>&1 | grep -io error | tail -n 1`";

    if [ "$is_app_down" == '' ]; then
        echo -e "Start up complete in "$total" sec!\n";
    else
        docker logs "${services[2]}" 2>> $app_err_log;
        echo -e "Error in "${services[2]}". Log saved to $app_err_log\n";
        echo -e "Powering down...\n";
        start=`date +%s`;
        docker.compose down;
        end=`date +%s`;
        down_time=$((end-start))
        echo -e "\nDocker down in "$down_time" sec!\n"
    fi
}

# wait for docker to generate logs before checking for any connection errors / 10 seconds seem to be enough
sleep 10s; err_check