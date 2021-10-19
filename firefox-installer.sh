#!/bin/bash

link=$(curl -Is "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US" | perl -n -e '/^Location: (.*)$/ && print "$1\n"')
current=$(pwd)/
linkfile=firelink.txt
currentfile=$(cat firelink.txt)
logo=Logos/logoinstall.txt
banner=$(cat $current$logo)
dist=$(cat /etc/*-release | grep "ID=" | cut -d "=" -f2 | head -n 1)
ub=Ubuntu
filename=$(find fire*.tar.bz2)
opt=$(find /opt -path /opt/firefox &> path.log)
ubuntu=false

white="\033[1;37m"
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
Purple="\033[0;35m"
Cyan="\033[0;36m"
Cafe="\033[0;33m"
Fiuscha="\033[0;35m"
blue="\033[1;34m"
nc="\e[0m"

rerun=0

clear

echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "$banner"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

sleep 1

if [ "$dist" = "$ub" ]; then
	echo -e " $red[$green Ubuntu detected !$red]$white You already have the latest versions from your repos$nc"
	echo ""
	echo "The current technique does not support your distro but we have a workaround"
	echo "Press [y] to proceed and [n] to terminate the script"

	read t

	if [ "$t" = "n" ]; then
		exit 1
	else
		ubuntu=true
	fi
fi

sleep 1
clear
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "$banner"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green Close any running instance of firefox $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"

read -rsp $'Press ENTER to continue...\n' -n1 key

sleep 1
clear
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "$banner"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green We have to uninstall the firefox in your system to prevent apt corruption $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"

echo "Press [y] to remove and [n] to terminate the script"

read y

if [ "$y" = "n" ]; then
	exit 1
else
	#ROOT PRIVILEGIES
	if [[ $EUID -ne 0 ]]; then
		sleep 1
		clear
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		echo "$banner"
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

        echo -e "$yellow[!]$white Needs root permissions to remove the existing firefox-esr or firefox package $yellow[!]$nc"
	fi

	sudo apt remove firefox-esr -y &>/dev/null
fi

sleep 1
clear
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "$banner"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green Sit back we have everything undercontrol $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────┙$nc\n"

# if hash firefox 2>/dev/null; then
# 	echo "" &>/dev/null
# else
	if [ ubuntu = false ]; then
		wget -c "http://security.ubuntu.com/ubuntu/pool/main/f/firefox/firefox_93.0+build1-0ubuntu0.18.04.1_amd64.deb" -q --show-progress
		sudo dpkg -i firefox_93.0+build1-0ubuntu0.18.04.1_amd64.deb &>/dev/null
		sudo apt-get -f install -y &>/dev/null
	else
		sudo apt remove firefox -y &>/dev/null
	fi
# fi

touch firelink.txt
echo "$link" > firelink.txt

if [[ "$filename" = *such* ]]; then #Check if the download file exist no
	wget -c -i firelink.txt -q --show-progress #downloading"
	if [[ $(bzip2 -tv $filename) = *ok* ]]; then #Check if the file is corrupt
		tar -xavf $current$downfile &>/dev/null#install
			if [ "$opt" = "/opt/firefox" ]; then
                sudo rm -rf /opt/firefox
	            sudo mv firefox /opt
			else
				sudo rm -rf /opt/firefox
				sudo mv firefox /opt
			fi
	else
		echo "Downloaded File corrupted"
		echo -e "$Cyan│$nc $red[$blue+$red]$green Please Check your network and press $green[y]$green to Retry $red[n]$red to Terminate the Script $red[$blue+$red]$Cyan │$nc"
		read x

		if [ "$x" = "n" ]; then
			exit 1
		else
			rerun=1
		fi
	fi

else
	bzip2 -tv $filename &> tar.log
	my1=$(cat tar.log)
	if [[ "$my1" = *ok* ]]; then 
			tar -xavf $current$filename &>/dev/null
		if [ "$opt" = "/opt/firefox" ]; then
            sudo rm -rf /opt/firefox
           	sudo mv firefox /opt
		else
			sudo rm -rf /opt/firefox
			sudo mv firefox /opt
		fi
	else
		echo "The Existing Zip File Corrupted Run 'rm -rf firefox*.tar.bz2' to remove it"
		exit 1
	fi
fi

if [ rerun = 1 ]; then
		rm -rf firefox*.tar.bz2
		wget -c -i firelink.txt -q --show-progress #downloading
		if [[ $(bzip2 -tv $filename) = *ok* ]]; then  #Check if the file is corrupt
			tar -xavf $current$downfile &>/dev/null #install
				if [ "$opt" = "/opt/firefox" ]; then
                    sudo rm -rf /opt/firefox
					sudo mv firefox /opt
				else
					sudo rm -rf /opt/firefox
					sudo mv firefox /opt
				fi
		else
    		echo "Downloaded File corrupted"
			echo -e "$Cyan│$nc $red[$blue+$red]$green Please Check your network and press $green[y]$green to Retry $red[n]$red to Terminate the Script $red[$blue+$red]$Cyan │$nc"
			read x

			if [ "$x" = "n" ]; then
    			exit 1
			else
				rerun=1
			fi
		fi
fi

if [[ "${ubuntu}" == "true" ]]; then
	dname=$(find *fire*.desktop)
	cname=firefox.desktop
	path=/usr/share/applications/
	echo -e "removing the the current .desktop file"
	sudo rm -rf $path$dname
	echo -e "copying the .desktop file"
	sudo cp $current$cname $path
	echo -e "making it executable"
	sudo chmod +x $path$cname
fi
exit
