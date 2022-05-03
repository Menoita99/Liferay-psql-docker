#!/bin/bash

home=/opt/Liferay-docker-files
backup_home=$home/backup

echo "Stoping liferay ..."

systemctl stop liferay

echo "--------------------------"
echo "Synchronizing folders..."
time docker-compose -f $home/docker-compose-backup.yml run backup
echo "--------------------------"
echo "Synchronization completed"
echo "--------------------------"

echo "Starting liferay..."
echo "To see liferay logs run:  docker-compose logs -f liferay"
systemctl start liferay

test -f $backup_home/backup-liferay.tar.gz.old && rm $backup_home/backup-liferay.tar.gz.old
test -f $backup_home/backup-liferay.tar.gz && mv $backup_home/backup-liferay.tar.gz $backup_home/backup-liferay.tar.gz.old

echo "--------------------------"
echo "Compressing backup..."
time tar -czf $backup_home/backup-liferay.tar.gz $backup_home/backup
echo "Backup complete"
echo "--------------------------"
