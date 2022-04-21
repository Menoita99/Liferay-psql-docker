#!/bin/bash

systemctl stop liferay

docker-compose -f docker-compose-backup.yml up

systemctl start liferay

test -f backup-liferay.tar.gz.old && rm backup-liferay.tar.gz.old
test -f backup-liferay.tar.gz && mv backup-liferay.tar.gz backup-liferay.tar.gz.old

tar -czvf backup-liferay.tar.gz ./backup
