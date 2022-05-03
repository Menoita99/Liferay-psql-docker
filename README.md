# Liferay Portal CE Docker Compose Environment

## Requirements

* Docker & Docker Compose - https://www.docker.com/

## Setup

Start the compose:

```
docker-compose up --build -d
```

Tail the log:

```
docker-compose logs -f liferay
```

Stop the stack

```
docker-compose stop
```

Destroy

```
docker-compose down
```

Upgrading liferay: https://learn.liferay.com/dxp/latest/en/installation-and-upgrades/upgrading-liferay/upgrade-basics/upgrading-via-docker.html

# Errors and notes

* If elastic search returns code 78
verify in the logs if it's cause is the vm.max_map_count error
if it is and you are running docker in wls run this 2 commands:

```
wsl -d docker-desktop
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
```

* If elastic search returns code 137 it may be because it runs out of memory, consider increasing the memory that docker uses and increasing the memory in the docker-compose.yml environment variable of the container.

* Elastic Documentation: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html



##  File System            

Docker containers are transient. Whenever you reboot a container, all changes on its file system are lost.

To quickly test changes without building a new image, map the host's file system to the container's file system.

Start the container with the option -v \$(pwd)/xyz123:/mnt/liferay to bridge \$(pwd)/xyz123 in the host 
operating system to /mnt/liferay on the container.

Files in the host directory $(pwd)/xyz123/files are also available in the container directory /mnt/liferay/files 
and will be copied to /opt/liferay before Liferay Portal starts.

For example, if you want to modify Tomcat's setenv.sh file, then place your changes in $(pwd)/xyz123/files/tomcat/bin/setenv.sh 
and setenv.sh will be overwritten in /opt/liferay/tomcat/bin/setenv.sh before Liferay Portal starts.


##  Scripts           

All scripts in the container directory /mnt/liferay/scripts will be executed before Liferay Portal starts. 
Place your scripts in $(pwd)/xyz123/scripts.


##  Deploy

Copy files to $(pwd)/xyz123/deploy on the host operating system to deploy modules to Liferay Portal at runtime.