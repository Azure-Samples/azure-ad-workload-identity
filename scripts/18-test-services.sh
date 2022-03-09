#!/bin/bash

# Variables
line=$(printf '%.s-' {1..80})
frontendHostName="todo.babosbird.com"
backendHostName="todoapi.babosbird.com"
red='\033[0;31m'
nocolor='\033[0m' # No Color

# Call the frontend service
echo $line
echo -e "${red}Call frontend service${nocolor}"
echo $line
curl -s https://$frontendHostName

# Call the backend service
echo $line
echo -e "${red}Call backend service${nocolor}"
echo $line
curl -s https://$backendHostName/api/todo | jq -r
echo $line