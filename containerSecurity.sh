#!/bin/bash

# this script works only if it is in the same dir as the Dockerfile / docker-compose.yml

# you need to have 3 different docker-compose.yml files:
# 1. local docker-compose.yml
# 2. setUpProduction.yml which only has the app and mongoDB services (WITHOUT any auth credentials)
# 3. production.yml which has everything it needs to set up an app with an auth enabled database and a 
# configured NGINX server + encryption  

app_name=$1

# set mongoDB admin user credentials with script arguments
username=$2
password=$3 # passwords that have spaces in them need to be inside single quotes 

if [[ $# -ne 3 ]]; then
    echo "Usage: ./containerSecurity.sh [APP NAME] [MONGO USERNAME] [MONGO PASSWORD]"
    exit
fi

mv setUpProduction.yml docker-compose.yml
echo -e "\nSetting up production...\n"

./startDocker.sh $app_name

docker exec -it mongo mongo admin --eval "db.createUser({ user: '${username}', pwd: '${password}', roles: [ { role: 'root', db: 'admin' } ] })"

docker.compose down

mv production.yml docker-compose.yml
echo -e "\nProduction environment set up.\n"

./startDocker.sh $app_name