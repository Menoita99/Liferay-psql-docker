Upgrading liferay:
https://learn.liferay.com/dxp/latest/en/installation-and-upgrades/upgrading-liferay/upgrade-basics/upgrading-via-docker.html

If elastic search returns code 78
verify in the logs if it's cause is the vm.max_map_count error
if it is and you are running docker in wls run this 2 commands:

wsl -d docker-desktop
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

Documentation: 
"https://hub.docker.com/r/liferay/portal"
"https://learn.liferay.com/dxp/latest/en/installation-and-upgrades/installing-liferay/using-liferay-docker-images.html"

IMPORTANT NOTES:

+-------------------------+
|  File System            |
+-------------------------+
Docker containers are transient. Whenever you reboot a container, all changes on its file system are lost.

To quickly test changes without building a new image, map the host's file system to the container's file system.

Start the container with the option -v $(pwd)/xyz123:/mnt/liferay to bridge $(pwd)/xyz123 in the host 
operating system to /mnt/liferay on the container.

Files in the host directory $(pwd)/xyz123/files are also available in the container directory /mnt/liferay/files 
and will be copied to /opt/liferay before Liferay Portal starts.

For example, if you want to modify Tomcat's setenv.sh file, then place your changes in $(pwd)/xyz123/files/tomcat/bin/setenv.sh 
and setenv.sh will be overwritten in /opt/liferay/tomcat/bin/setenv.sh before Liferay Portal starts.

+-------------------------+
|  Scripts                |
+-------------------------+
All scripts in the container directory /mnt/liferay/scripts will be executed before before Liferay Portal starts. 
Place your scripts in $(pwd)/xyz123/scripts.

+-------------------------+
|  Deploy                 |
+-------------------------+
Copy files to $(pwd)/xyz123/deploy on the host operating system to deploy modules to Liferay Portal at runtime.