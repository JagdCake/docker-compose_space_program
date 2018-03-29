#!/bin/bash

# this script works only if it is in the same dir as the Dockerfile / docker-compose.yml

# set the app name with the first script argument
app_name=$1

if [[ $# -ne 1 ]]; then
    echo "Usage: ./startDocker.sh [APP NAME]"
    exit
fi

dir_check="`ls . | grep -io docker-compose.`"

red=`tput setaf 1`
no_color=`tput sgr0`

if [[ $dir_check == '' ]]; then
    echo -e "Wrong directory, docker-compose.y(a)ml ${red}not found${no_color}!"
    exit
fi

start_up() {
    start=`date +%s`
    docker.compose build; docker-compose build
    end=`date +%s`
    build_time=$((end-start))
    echo -e "\nBuild complete in "$build_time" sec!\n"

    start=`date +%s`
    docker.compose up -d; docker-compose up -d
    end=`date +%s`
    up_time=$((end-start))
    echo -e "\nDocker up in "$up_time" sec!\n"

    total=$((build_time+up_time))
}

start_up

# may be needed for the first (local) start up
conf_copy() {
    docker cp ./nginx/nginx.conf nginx:/etc/nginx
    docker exec -it nginx service nginx reload
}

#sleep 10s; conf_copy

err_log=~/Containers/$app_name/logs/err

err_check() {
    # the snap version of docker uses 'docker.compose' instead of 'docker-compose'
    something_is_down="`docker.compose logs; docker-compose logs | grep -io error | tail -n 1`"

    if  [ "$something_is_down" == '' ]; then
        echo -e "Start up complete in "$total" sec!\n"
    else 
        docker.compose logs; docker-compose logs > $err_log
        # assign the line numbers (only) to an array
        log_lines="(`grep -in error $err_log | cut -d : -f 1`)"
        echo -e "Error(s)! Log saved to $err_log\nError(s) at line(s): "${log_lines[@]}"\n"
        echo -e "Powering down...\n"

        start=`date +%s`
        docker.compose down; docker-compose down
        end=`date +%s`

        down_time=$((end-start))
        echo -e "\nDocker down in "$down_time" sec!\n"
    fi
}

# wait for docker.compose to generate logs before checking for any errors / 10 seconds seem to be enough
sleep 10s; err_check
