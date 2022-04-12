Upgrading liferay:
https://learn.liferay.com/dxp/latest/en/installation-and-upgrades/upgrading-liferay/upgrade-basics/upgrading-via-docker.html

If elastic search returns code 78
verify in the logs if it's cause is the vm.max_map_count error
if it is and you are running docker in wls run this 2 commands:

wsl -d docker-desktop
sudo sysctl -w vm.max_map_count=524288