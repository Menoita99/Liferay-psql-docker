#!/bin/bash

home=/opt/Liferay-docker-files

read -p "This action will override the current volumes of this application.\nDo you want to proceed?\n" 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Stoping liferay ..."

    systemctl stop liferay

    echo "--------------------------"
    echo "Restoring..."
    time docker-compose -f $home/docker-compose-restore.yml run restore
    echo "--------------------------"
    echo "Restore completed"
    echo "--------------------------"

    echo "Starting liferay..."
    echo "To see liferay logs run:  docker-compose logs -f liferay"
    systemctl start liferay
fi