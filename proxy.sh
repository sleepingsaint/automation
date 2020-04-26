#!/bin/bash
# please don't delete the above line

# author : sleepingsaint
# github : https://github.com/sleepingsaint
# description : it is a simple shell script to add the proxies to apt.conf 
# and profile (.bashrc file) 
# resource : https://medium.com/@krish.raghuram/setting-up-proxy-in-ubuntu-95058da0b2d4

# apt proxy --> Acquire::http::proxy “http://<user>:<pass>@<proxy>:<port>/”; 
# profile proxy --> export http_proxy=http://<user>:<pass>@<proxy>:<port>/

# the proxy conf path should be a absolute path (/home/<user>/<some_place_on_computer>/proxy.conf) 
# not relative path (./proxy.conf)

PROXY_CONF_PATH=""
APT_PROXY_PATH="/etc/apt/apt.conf"
BASHRC_PATH="/home/$USER/.bashrc"

sudo echo

source $PROXY_CONF_PATH

protocols=("http" "https" "ftp" "socks")


add_proxy(){
    echo "[ ADDING PROXIES ]"
    echo

	echo "---- APT PROXIES ----"
    apt_proxy=0
	for protocol in "${protocols[@]}"
	do
		proxy_entry="Acquire::${protocol}::proxy \"$protocol://$username:$password@$hostname:$port/”;"
        sudo grep -q "$proxy_entry" $APT_PROXY_PATH
        if [ $? -eq 1 ]
		then
			echo $proxy_entry | sudo tee -a $APT_PROXY_PATH
            apt_proxy=1
		fi
	done
    if [[ $apt_proxy == 0 ]];then
        echo "apt proxies already configured."
    fi

    echo

	echo "---- BASHRC ----"
    bash_proxy=0
	for protocol in "${protocols[@]}"
	do
        proxy_entry="export ${protocol}_proxy=$protocol://$username:$password@$hostname:$port/"
		sudo grep -q "$proxy_entry" $BASHRC_PATH
		if [ $? -eq 1 ]
		then
			echo $proxy_entry | sudo tee -a $BASHRC_PATH
            bash_proxy=1
		fi
	done
    
    if [[ $bash_proxy == 0 ]];then
        echo "bash profile is already configured"
    fi
    
    echo
	echo "(done!)"
    echo
}

remove_proxy(){
    echo "[ REMOVING PROXIES....... ]"

	for protocol in "${protocols[@]}"
	do	
		sudo sed -i "/$protocol/d" $APT_PROXY_PATH
	done
	
    for protocol in "${protocols[@]}"
	do
		sudo sed -i "/$protocol/d" $BASHRC_PATH
	done

    echo "(done!)"
    echo
}

list_proxies(){
    echo "[ LISTING PROXIES ]"
    
    echo
    
    apt_proxy=0
    echo "---- APT PROXIES ----"
    for protocol in "${protocols[@]}"
	do
        grep -w "$protocol" $APT_PROXY_PATH;
        if [ $? -eq 0 ]
        then
            apt_proxy=1
        fi
    done
    
    if [[ $apt_proxy == 0 ]];then
        echo "No proxies listed."
    fi

    echo
    
    bash_proxy=0
    echo "---- BASHRC PROXIES ----"
    for protocol in "${protocols[@]}"
	do
        grep -w "$protocol" $BASHRC_PATH;
        if [ $? -eq 0 ]
        then
            bash_proxy=1
        fi
	done
    if [[ $bash_proxy == 0 ]];then
        echo "No proxies listed."
    fi

    echo
    echo "(done!)"

    echo

}

edit_conf(){
    echo -e "Select the following options to change. Enter options seperated by space."
    read -p "[ hostname / h, port, username / u, password / p ] : " -a options

    for option in "${options[@]}"
    do
        if [[ $option == "username" ]] || [[ $option == "u" ]]
        then
            read -p "username : " username

        elif [[ $option == "password" ]] || [[ $option == "p" ]]
        then
            read -sp "password : " password
            echo

        elif [[ $option == "hostname" ]] || [[ $option == "h" ]]
        then
            read -p "hostname : " hostname
        
        elif [[ $option == "port" ]]
        then
            read -p "port : " port
    
        else
            echo "Invalid argument."
        fi
    done

    sudo sed -i "/hostname/d" $PROXY_CONF_PATH
    sudo sed -i "/port/d" $PROXY_CONF_PATH
    sudo sed -i "/username/d" $PROXY_CONF_PATH
    sudo sed -i "/password/d" $PROXY_CONF_PATH
    
    echo
    echo "---- proxy configuration ----"
    echo "hostname=$hostname" | sudo tee -a $PROXY_CONF_PATH
    echo "port=$port" | sudo tee -a $PROXY_CONF_PATH
    echo "username=$username" | sudo tee -a $PROXY_CONF_PATH
    echo "password=$password" | sudo tee -a $PROXY_CONF_PATH

}

# adding proxies
if [[ $1 == "--add" ]] || [[ $1 == "-a" ]]
then
    add_proxy

# remove proxy
elif [[ $1 == "--remove" ]] || [[ $1 == "-r" ]]
then
    remove_proxy

# update proxy
elif [[ $1 == "--update" ]] || [[ $1 == "-u" ]]
then
    remove_proxy
    add_proxy

# listing proxies
elif [[ $1 == "--list" ]] || [[ $1 == "-l" ]]
then
    list_proxies

# editing proxy configuration
elif [[ $1 == "--edit" ]] || [[ $1 == "-e" ]]
then
    edit_conf

# display help screen
elif [[ $1 == "--help" ]] || [[ $1 == "-h" ]]
then
    echo "--------------------- Script to edit the APT proxies and Environment variables --------------------------"
    echo "Useful to set proxies in linux on the fly. You also need to manually set the proxy in your network manager"
    echo 
    echo "Usage : "
    echo
    echo "--add / -a    : adds the respective proxies and env variables based on the proxy.conf file."
    echo "--remove / -r : removes the proxies and env variables."
    echo "--update / -u : Removes and add the proxies based on the proxy.conf file"
    echo "--list / -l   : list all the proxies in function."
    echo "--edit / -e   : lets you edit the proxy.conf from terminal."
    echo "                Provide the options seperated by space. Enter the new values for the respective fields."
    echo "                Don't forget to run script with --remove and --add tags to make the changes."
    echo "--help / -h   : Displays the help screen."
fi


