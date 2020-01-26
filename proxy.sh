#!/bin/bash
# please don't delete the above line

# author : sleepingsaint
# github : https://github.com/sleepingsaint
# description : it is a simple shell script to add the proxies to apt.conf 
# and profile (.bashrc file) 
# resource : https://medium.com/@krish.raghuram/setting-up-proxy-in-ubuntu-95058da0b2d4

# uncomment (remove the #) symbol to add the proxy to proxy list
# usually the http, https proxy is more enough for our needs
# if you want to add some other feel free to do so
# you can use the below templates to add proxies like socks e.t.c

# apt proxy --> Acquire::http::proxy “http://<user>:<pass>@<proxy>:<port>/”; 
# profile proxy --> export http_proxy=http://<user>:<pass>@<proxy>:<port>/

apt_proxy_list=(
	'Acquire::ftp::proxy "http://172.16.2.30:8080/";'
	'Acquire::http::proxy "http://172.16.2.30:8080/";'
	'Acquire::https::proxy "http://172.16.2.30:8080/";'
)

bashrc_proxy_list=(
	'export http_proxy=http://172.16.2.30:8080/'
	'export https_proxy=https://172.16.2.30:8080/'
)

read -p "Change Proxy add / remove Enter [a/r]: " proxy_change_state

# function to handle the addition to proxies
add_proxy(){
	echo "adding proxies to /etc/apt/apt.conf..."
	for i in "${apt_proxy_list[@]}"
	do
		sudo grep -q "$i" /etc/apt/apt.conf
		if [ $? -eq 1 ]
		then
			echo $i | sudo tee -a /etc/apt/apt.conf
		fi
	done

	echo "adding proxies to ~/.bashrc..."
	for i in "${bashrc_proxy_list[@]}"
	do
		sudo grep -q "$i" ~/.bashrc
		if [ $? -eq 1 ]
		then
			echo $i | sudo tee -a ~/.bashrc
		fi
	done
	echo "done!"
}

# function to handle the removal of proxies
remove_proxy(){
	echo "removing proxies from /etc/apt/apt.conf file..."
	for i in "${apt_proxy_list[@]}"
	do	
		temp=$(echo "$i" | cut -d' ' -f1)
		sudo sed -i "/$temp/d" /etc/apt/apt.conf
	done
	echo "removing proxies from ~/.bashrc..."
	for i in "${bashrc_proxy_list[@]}"
	do
		temp=$(echo "$i" | cut -d'=' -f1)
		sudo sed -i "/$temp/d" ~/.bashrc
	done
	echo "done!"
}

if [ $proxy_change_state == "a" ]
then
	# adding proxies
	add_proxy
elif [ $proxy_change_state == "r" ]
then
	# removing proxies
	remove_proxy
fi