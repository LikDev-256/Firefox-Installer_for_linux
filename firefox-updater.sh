#!/bin/bash

link=$(curl -Is "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US" | perl -n -e '/^Location: (.*)$/ && print "$1\n"')
current=$(pwd)/
linkfile=firelink.txt
downfile=$(basename "$link")
filename=$(find fire*.tar.gz)
currentfile=$(cat firelink.txt)
banner=$(cat logo.txt)

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

function download&install() {
	wget -c -i firelink.txt #downloading
		if gzip -t "$downfile"; then #Check if the file is corrupt
			tar -xavf $current$downfile #install
				if [ ! -f /opt/firefox ]; then
					sudo rm -rf /opt/firefox
					sudo mv firefox /opt
				else
					sudo mv firefox /opt
				fi
		else
    		  echo "Downloaded File corrupted"
    		  exit 1
		fi

}

function install() {

	tar -xavf $current$filename
		if [ ! -f /opt/firefox ]; then
			sudo rm -rf /opt/firefox
			sudo mv firefox /opt
		else
			sudo mv firefox /opt
		fi

}

echo "---------------------------------------------------------------------------------------------------------------------------------"
echo "$banner"
echo "---------------------------------------------------------------------------------------------------------------------------------"

echo -e "$Cyan╔───────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green NOTICE Please close the running instance of the firefox before proceeding $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖───────────────────────────────────────┙$nc\n"

sleep 10

echo -e "$Cyan╔───────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green Don't worry we'll update your browser in no time $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖───────────────────────────────────────┙$nc\n"

if [ ! -f $current$linkfile ]; then #Check if the link log exsist no
	touch firelink.txt
	echo "$link" > firelink.txt

	if [ ! -f $current$downfile ]; then #Check if the download file exist no
		download&install
	else
		if gzip -t "$current$filename"; then
			install
		else
    		  echo "The Existing Zip File Corrupted Run clean.sh script to remove it"
    		  exit 1
		fi
	fi

else
	if [ "$(cat firelink.txt)" = "$link" ]; then
		echo "The last run has confirmed that you're using the newest version of Firefox"
	else
		echo "$link" > firelink.txt
		download&install
	fi
fi


