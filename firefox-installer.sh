#!/bin/bash

rootcheck() {
	#ROOT PRIVILEGIES

	if [[ $(id -u) -gt 0 ]] && [ $deb = True ]; then
        echo -e "$yellow[!]$white Needs root permissions to run the script $yellow[!]$nc"
		echo -e "$red Please provide permissions$nc"
		[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
	fi

	if [[ $(id -u) -eq 0 ]] && [ $arch = True ]; then
		echo -e "$yellow[!]$white Arch based cannot run the script as root $yellow[!]$nc"
		exit 1
	fi
}

function checkdist() {

		if [[ -n $(cat /etc/*-release | sed -n /'debian'/p) ]]; then
			echo "Debian based"
				deb=True
		elif [[ -n $(cat /etc/*-release | sed -n /'arch'/p) ]]; then
			echo "Arch based"
				arch=True
		else
			echo -e "$red Sorry Your distro is not supported by the installer 😪$nc"
			echo -e "Please be kind to wait or contribute yourself"
			exit 1
		fi

}

DownloadCheckfile() {
		cd $debpkgdir
		echo "Getting the original tar checksum ..."
		tarshasum=$(curl https://ftp.mozilla.org/pub/firefox/releases/$pkgver/SHA256SUMS --progress-bar | grep linux-x86_64/en-US/$tarname | cut -d " " -f1)
		#echo -e "tarshasum =  $tarshasum"
		#echo -e "currentfile =  $currentfile"
		sleep 1
		bannershow
		echo ""
		echo -e "Downloading the tar archive"
		echo ""
		echo -e "This might take while ..."
		echo -e "Good time to get a sip of coffee 😉"
		wget -c -i $linkfile -q --show-progress #downloading the tar
		# Check the itergrity of the downloaded file
		bannershow
		currentshasum=$(sha256sum $debpkgdir$tarname| cut -d " " -f1)
			if [[ "$currentshasum" == "$tarshasum" ]]; then
				echo ""
				echo -e "File integrity check successful [✅]"
				bannershow
			else
				echo ""
				echo -e "File integrity check unsuccessful [❌]"
				echo -e "File maybe corrupted"
				bannershow
				
				try_this2() {
				echo -e "Retrying the download again if you wanna proceed press [y] or [n] terminate"
				while true; do
					read -n1 -r
					[[ $REPLY == 'y' ]] && break
					[[ $REPLY == 'n' ]] && exit 1
				done
				echo
				echo "Continuing ..."
				}
				try_this2
						echo ""
						echo -e "Retying download ..."
						rm -rf *.tar.bz2
						echo ""
						echo -e "This might take while ..."
						echo -e "Good time to get a sip of coffee 😉"
						wget -c -i $linkfile -q --show-progress
							if [[ "$currentshasum" == "$tarshasum" ]]; then
								echo ""
								echo -e "File integrity check successful [✅]"
								bannershow
								#echo -e "Extracting the file"
							else
								echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────────╗$nc"
								echo -e "Encoutered a issue while downloading the file Please check your CONNECTION and rerun the script"
								echo -e "OR Report the issue to https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
								echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────────┙$nc\n"
								sleep 10
							fi
			fi
}

connectivitycheck() {
	
# echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
connect=$(ping -q -c1 google.com &>/dev/null && echo 1 || echo 0)

if [ $connect -eq 1 ]; then
    echo "Network connectivity is up good to go 😃"

else
	bannershow
    echo "Seems to be the network is down or very slow 🤔"
	echo "Network connectivity is essential for this script to run properly 😶"
	echo "Rerun the script after properly connecting ...."
	sleep 10
	exit 1
fi

}

bannershow() {
	clear

	echo ""
	for (( c=1; c<=($width/3); c++ ))
	do
		echo -ne "/"
		echo -ne "*"
		echo -ne '\'
	done
	echo ""
	echo ""
	echo "$banner"
	echo ""
	for (( c=1; c<=($width/3); c++ ))
	do
		echo -ne "/"
		echo -ne "*"
		echo -ne '\'
	done
	echo ""
	echo ""

	sleep 1
}

cleanup() {
	bannershow

	echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
	echo -e "$Cyan│$nc $red[$green+$red]$green Check if your install proceeded successfully $red[$green+$red]$Cyan │$nc"
	echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"
	sleep 3

	echo ""

	echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
	echo -e "$Cyan│$nc $red[$green+$red]$green We can save your space. If you don't need the build files $red[$green+$red]$Cyan │$nc"
	echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"
	sleep 3

	check() {
	echo -e "Press [y] to $red Clean the build files and [n] to terminate the script$nc"
	while true; do
		read -n1 -r
		[[ $REPLY == 'y' ]] && break
		[[ $REPLY == 'n' ]] && exit 1
	done
	echo
	echo "Continuing ..."
	}
	check
	bannershow
	#////////////////////////////////////////////
	#clean build
		echo -e "Cleaning BUILD environment ..."
		echo ""
		cd $debpkgdir
		echo -e "Cleaning debian folder ..."
		ls -1 | grep -E -v 'firefox.desktop|control|firefox.sh' | xargs rm -rf
		cd $current
		sleep 5

		echo ""

		cd $archbuildir
		echo -e "Cleaning arch folder ..."
		ls -1 | grep -E -v 'firefox.install|firefox.desktop|PKGBUILD|firefox.sh' | xargs rm -rf
		cd $current
		sleep 5

	bannershow

		echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
	echo -e "$Cyan│$nc $red[$green+$red]$green We can save more space. If you don't need the script it self $red[$green+$red]$Cyan │$nc"
	echo -e "$Cyan│$nc $red[$green+$red]$green We can clean it for you. IT'S ACTUALLY SUICIDE ... $red[$green!$red]$Cyan │$nc"
	echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"
	sleep 3

	check() {
	echo -e "Press [y] to $red Clean the script and [n] to terminate the script$nc"
	while true; do
		read -n1 -r
		[[ $REPLY == 'y' ]] && break
		[[ $REPLY == 'n' ]] && exit 1
	done
	echo
	echo "Continuing ..."
	}
	check
		cd ~/
		rm -rf $current
		#echo $current
		sleep 5
		bannershow
		exit 1
}

function install-requirements {
	echo ""
	echo -e "$red Updating Upgrading & Intstalling nessecery stuff ...$nc"
	sleep 5
if VERB="$( which dpkg )" 2> /dev/null; then
	bannershow
   echo "Debian-based"
   echo "----------------------------------->>>"
   sudo apt-get update 2> /dev/null && sudo apt-get upgrade 2> /dev/null
   sudo apt-get install wget curl xdotool
elif VERB="$( which dnf )" 2> /dev/null; then
	bannershow
   echo "RedHat-based"
   sudo dnf update &&
   sudo dnf install wget curl xdotool
elif VERB="$( which pacman )" 2> /dev/null; then
	bannershow
   echo "Arch-based"
   echo "----------------------------------->>>"
   sudo pacman -Sy --needed wget curl xdotool
elif VERB="$( which zypper )" 2> /dev/null; then
	bannershow
   echo "openSUSE-based"
   su -c 'zypper up && wget curl xdotool'
elif VERB="$( which xbps-install )" 2> /dev/null; then
	bannershow
   echo "Void-based"
   sudo xbps-install -Sy wget curl xdotool
elif VERB="$( which eopkg )" 2> /dev/null; then
	bannershow
   echo "Solus-based"
   sudo eopkg install wget curl xdotool
elif VERB="$( which emerge )" 2> /dev/null; then
	bannershow
    echo "Gentoo-based"
    sudo emerge -av wget/curl/xdotool
else
   echo "I can't find your package manager!"
   exit;
fi
bannershow
}

# Init 
banner=$(cat $current'Logos/logoinstall.txt')
width=$(tput cols)
# /////////////////////////////////////////////////////////////////////////////////////////////
# Distros
basedist=$(cat /etc/*-release | grep "ID_LIKE=" | cut -d "=" -f2 | head -n 1)
dist=$(cat /etc/*-release | grep "ID=" | cut -d "=" -f2 | head -n 1)
#declare -a distros=(debian arch)
arch=False
deb=False

bannershow
# echo -e "The symbols or letters are added for easthetic perposes only ...."
# echo -e "Not meant to mean anything"
connectivitycheck
sleep 7
checkdist
if [ $deb = True ]; then
	rootcheck
fi
install-requirements
rootcheck

# Files and paths
current=$(pwd)/
linkfile="$current"logs/firelink.txt
verfile="$current"logs/firever.txt
#filename=$(find fire*.tar.bz2)
#opt=$(find /opt -path /opt/firefox &> logs/path.log)

link=$(curl -Is "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US" | perl -n -e '/^Location: (.*)$/ && print "$1\n"')
curl -Is "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US" | perl -n -e '/^Location: (.*)$/ && print "$1\n"' > $linkfile
currentfile=$(cat $linkfile)
banner=$(cat $current'Logos/logoinstall.txt')

# /////////////////////////////////////////////////////////////////////////////////////////////
# Pkg vars
pkgname=firefox
pkgver=$(cat $linkfile | cut -d "/" -f 7)
archbuildir=$current"firefox-arch"
archbuild=/PKGBUILD

# /////////////////////////////////////////////////////////////////////////////////////////////
# Deb var
debpkgname=$pkgname'_'$pkgver'_amd64'
debpkg=$debpkgname'.deb'
debpkgdir=$current'firefox-deb/'
debpkginstall=$debpkgdir$debpkgname

# /////////////////////////////////////////////////////////////////////////////////////////////
# Colors diclarations 
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

# tarname
tarname=$pkgname"-"$pkgver".tar.bz2"

#xdotool key function+F11

#bannershow
#xdotool key function+F11
#rootcheck
#deb=True
# echo $current
# echo $linkfile
#sleep 6

bannershow

echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green Close any running instance of firefox $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"
sleep 2
try_this() {
  echo -n "Press SPACE to continue  ... "
  while true; do
    read -n1 -r
    [[ $REPLY == ' ' ]] && break
  done
  echo
  echo "Continuing ..."
}
try_this

bannershow

echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green We have to uninstall the current firefox in your system to prevent Package Manager corruption $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"
sleep 1

try_this1() {
  echo "Press [y] to remove and [n] to terminate the script"
  while true; do
    read -n1 -r
    [[ $REPLY == 'y' ]] && break
	[[ $REPLY == 'n' ]] && exit 1
  done
  echo
  echo "Continuing ..."
}
try_this1

bannershow
echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green Sit back we have everything undercontrol $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────┙$nc\n"
echo -e "Just kidding some confirmations only ..."
echo ""
sleep 5
bannershow
			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "If you Encouter a issue Please Report the issue to,"
			echo -e "https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────────┙$nc\n"
sleep 5

if [ $deb = True ]; then
		# make pkg

		cd $debpkgdir
		DownloadCheckfile
		# echo "Extracting file This might take a while ..."

		# echo -e "\\r${CHECK_MARK} thing 1 done"
		# sleep 4

		bannershow

		mkdir $debpkginstall

		# echo "$debpkginstall"
		sleep 5

		echo "Creating directory structure..."
		echo ""
		mkdir -p "$debpkginstall"/usr/bin
		mkdir -p "$debpkginstall"/usr/share/applications
		mkdir -p "$debpkginstall"/opt
		mkdir -p "$debpkginstall"/DEBIAN
		sleep 3

		echo "Moving stuff in place..."
		echo ""
		# Install
		# mv firefox -t "$debpkginstall"/opt/
		echo -e "Extracting file ..."
		echo ""
		echo -e "This might take while ..."
		echo -e "Good time to get a sip of coffee 😉"
		sleep 5
		tar -xavf $debpkgdir$tarname -C "$debpkginstall"/opt/ > /dev/null
		install -m755 firefox.sh "$debpkginstall"/usr/bin/firefox
		install -m644 *.desktop "$debpkginstall"/usr/share/applications/
		sleep 3

		echo -e "Linking icons ..."
		echo ""
		for i in 16x16 32x32 48x48 64x64 128x128; do
			install -d "$debpkginstall"/usr/share/icons/hicolor/$i/apps/
			ln -s "$debpkginstall"/opt/firefox/browser/chrome/icons/default/default${i/x*}.png \
				"$debpkginstall"/usr/share/icons/hicolor/$i/apps/firefox.png
		done
		sleep 3

		# echo -e "Linking dictionaries ..."
		# echo ""
		# ln -Ts /usr/share/hunspell "$debpkginstall"/opt/firefox/dictionaries
		# ln -Ts /usr/share/hyphen "$debpkginstall"/opt/firefox/hyphenation

		# sleep 3

		# Use system certificates
		echo -e "Linking certificates ..."
		ln -sf /usr/lib/libnssckbi.so "$debpkginstall"/opt/firefox/libnssckbi.so

		echo "Updating versions in the control file ..."
		sed -i 's/Version:.*/Version: '$pkgver/g "$debpkgdir"control
		cp control "$debpkginstall"/DEBIAN/

		sleep 3

		bannershow

		echo -e "Starting Debian PKGBUILD ..."
		echo ""
		echo -e "This might take while ..."
		echo -e "Good time to get a sip of coffee 😉"
		echo ""
		sleep 1

		dpkg-deb --build --root-owner-group $debpkgname

		echo -e "PKG BUILD SUCCESSFUL"
		echo ""
		sleep 4
		bannershow

		echo -e "Removing the current Firefox ..."
		sudo apt remove firefox firefox-esr -y
		sleep 3
		bannershow
		echo ""
		echo -e "Installing dependencies for the package ..."
		sleep 3
		sudo apt install ffmpeg pulseaudio -y
		bannershow
		echo ""
		echo -e "Installing the previously built package"
		sleep 3
		sudo dpkg -i *.deb
		bannershow
		sudo apt-get install -f
		sudo chown -R :$USER /opt/firefox

			bannershow

			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "$Cyan│$nc $red[$green+$red]$green Installation Successful $red[$green+$red]$Cyan │$nc"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────┙$nc\n"

			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "If you Encouter a issue Please Report the issue to,"
			echo -e "https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────────┙$nc\n"
			
			echo ""
			sleep 10

			cleanup
			#xdotool key function+F11

			exit 1

elif [ $arch = True ]; then
	sudo pacman -Syu
	bannershow
	sudo pacman -S --noconfirm --needed fakeroot git base-devel yay
	bannershow
	sudo yay -Su
	bannershow

        echo "Entering BUILD Directory ..."
		cd $archbuildir
		#echo $archbuildir
		sleep 5
        sed -i "s/pkgver=.*/pkgver=$pkgver/" $archbuildir$archbuild
		bannershow
		makepkg -Acis
		sudo chown -R :$USER /opt/firefox
		sleep 2

			bannershow

			echo -e "$Cyan╔─────────────────────────────────────────────────────────────╗$nc"
			echo -e "$Cyan│		$nc $red[$green+$red]$green Installation Successful $red[$green+$red]$Cyan	   │$nc"
			echo -e "$Cyan┖───────────────────────────────────────────────────-─────────┙$nc\n"

			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "If you Encouter a issue Please Report the issue to,"
			echo -e "https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────────┙$nc\n"

			echo ""
			sleep 10

			cleanup
			
			#xdotool key function+F11

			exit 1
fi
