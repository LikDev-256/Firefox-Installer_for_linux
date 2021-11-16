#!/bin/bash

rootcheck() {
	#ROOT PRIVILEGIES
	if [[ $EUID -ne 0 ]]; then

        echo -e "$yellow[!]$white Needs root permissions to run the script $yellow[!]$nc"
		echo -e "$red Please provide permissions$nc"
		[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
	fi
}

function checkdist() {

		if [[ -n $(cat /etc/*-release | sed -n /'debian'/p) ]]; then
			#echo "debian"
				deb=True
		elif [[ -n $(cat /etc/*-release | sed -n /'arch'/p) ]]; then
			#echo "arch"
				arch=True
		else
			echo -e "$red Your distro is not supported by the installer$nc"
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
		wget -c -i $link -q --show-progress #downloading the tar
		# Check the itergrity of the downloaded file
		bannershow
		currentshasum=$(sha256sum $debpkgdir$tarname| cut -d " " -f1)
			if [[ "$currentshasum" == "$tarshasum" ]]; then
				echo ""
				echo -e "File integrity check successful [✅]"
			else
				echo ""
				echo -e "File integrity check unsuccessful [❌]"
				echo -e "File maybe corrupted"
				echo -e "Retrying the download again if you wanna proceed press [y] or [n] terminate"
				read t

					if [[ "$t" == "y" ]]; then
						echo ""
						echo -e "Retying download ..."
						rm -rf *.tar.bz2
						wget -c -i $linkfile -q --show-progress
						currentshasum=$(sha256sum $debpkgdir$tarname)
							if [["$currentshasum" == "$tarshasum"]]; then
								echo ""
								echo -e "File integrity check successful [✅]"
								echo -e "Extracting the file"
							else
								echo -e "Encoutered a issue while downloading the file Please check your CONNECTION and rerun the script"
								echo -e "OR Report the issue to https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
							fi
					else
						exit 1
					fi 
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

function install-requirements {
if VERB="$( which dpkg )" 2> /dev/null; then
	bannershow
   echo "Debian-based"
   sudo apt-get update 2> /dev/null && sudo apt-get upgrade 2> /dev/null &&
   sudo apt-get install wget curl dpkg-deb
elif VERB="$( which dnf )" 2> /dev/null; then
	bannershow
   echo "RedHat-based"
   sudo dnf update &&
   sudo dnf install wget curl
elif VERB="$( which pacman )" 2> /dev/null; then
	bannershow
   echo "Arch-based"
   sudo pacman -Sy --needed wget curl
elif VERB="$( which zypper )" 2> /dev/null; then
	bannershow
   echo "openSUSE-based"
   su -c 'zypper up && zypper install dialog wmctrl'
elif VERB="$( which xbps-install )" 2> /dev/null; then
	bannershow
   echo "Void-based"
   sudo xbps-install -Sy wget curl
elif VERB="$( which eopkg )" 2> /dev/null; then
	bannershow
   echo "Solus-based"
   sudo eopkg install wget curl
elif VERB="$( which emerge )" 2> /dev/null; then
	bannershow
    echo "Gentoo-based"
    sudo emerge -av wget/curl
else
   echo "I can't find your package manager!"
   exit;
fi
bannershow
}

# Files and paths
current=$(pwd)/
linkfile=$pwd'logs/firelink.txt'
verfile=$pwd'logs/firever.txt'
#filename=$(find fire*.tar.bz2)
opt=$(find /opt -path /opt/firefox &> logs/path.log)

link=$(curl -Is "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US" | perl -n -e '/^Location: (.*)$/ && print "$1\n"')
curl -Is "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US" | perl -n -e '/^Location: (.*)$/ && print "$1\n"' > $linkfile
currentfile=$(cat $linkfile)
banner=$(cat $current'Logos/logoinstall.txt')

# /////////////////////////////////////////////////////////////////////////////////////////////
# Distros
basedist=$(cat /etc/*-release | grep "ID_LIKE=" | cut -d "=" -f2 | head -n 1)
dist=$(cat /etc/*-release | grep "ID=" | cut -d "=" -f2 | head -n 1)
#declare -a distros=(debian arch)
arch=False
deb=False

# /////////////////////////////////////////////////////////////////////////////////////////////
# Pkg vars
pkgname=firefox
pkgver=$(cat $linkfile | cut -d "/" -f 7)
archbuildir=$current"firefox-arch"
archbuild=/PKGBUILD

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
width=$(tput cols)

# tarname
tarname=$pkgname"-"$pkgver".tar.bz2"

xdotool key function+F11
bannershow
#xdotool key function+F11
#rootcheck

checkdist
install-requirements

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


echo -e "$Cyan╔──────────────────────────────────────────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green We have to uninstall the current firefox in your system to prevent Package Manager corruption $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖──────────────────────────────────────────────────────────────────────────────────────────────────────────┙$nc\n"
sleep 1
echo "Press [y] to remove and [n] to terminate the script"

read h

if [ "$h" = "n" ]; then
	exit 1
else

bannershow
echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────╗$nc"
echo -e "$Cyan│$nc $red[$green+$red]$green Sit back we have everything undercontrol $red[$green+$red]$Cyan │$nc"
echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────┙$nc\n"
echo ""
echo -e "Just kidding some confirmations only ..."
echo ""
			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "If you Encouter a issue Please Report the issue to,"
			echo -e "https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────────┙$nc\n"
sleep 5

if [ $deb = True ]; then
		# make pkg
		debpkgname=$pkgname'_'$pkgver'_amd64'
		debpkgdir=$current'firefox-deb/'
		debpkginstall=$debpkgdir$debpkgname
		cd $debpkgdir
		DownloadCheckfile
		#echo "Extracting file This might take a while ..."
		echo -e "Extracting file This might take a while ..."
		sleep 1
		tar -xavf $debpkgdir$tarname > /dev/null &
		echo -e "\\r${CHECK_MARK} thing 1 done"
		sleep 1

		bannershow

		mkdir $debpkginstall

		echo "$debpkginstall"
		#sleep 5

		echo "Creating directory structure..."
		mkdir -p "$debpkginstall"/usr/bin
		mkdir -p "$debpkginstall"/usr/share/applications
		mkdir -p "$debpkginstall"/opt
		mkdir -p "$debpkginstall"/DEBIAN
		sleep 2

		echo "Moving stuff in place..."
		# Install
		mv firefox "$debpkginstall"/opt/
		install -m755 firefox.sh "$debpkginstall"/usr/bin/firefox
		install -m644 *.desktop "$debpkginstall"/usr/share/applications/
		sleep 2

		echo -e "Linking icons"
		for i in 16x16 32x32 48x48 64x64 128x128; do
			install -d "$debpkginstall"/usr/share/icons/hicolor/$i/apps/
			ln -s "$debpkginstall"/opt/firefox/browser/chrome/icons/default/default${i/x*}.png \
				"$debpkginstall"/usr/share/icons/hicolor/$i/apps/firefox.png
		done
		sleep 2

		echo -e "Linking dictionaries"
		ln -Ts /usr/share/hunspell "$debpkginstall"/opt/firefox/dictionaries
		ln -Ts /usr/share/hyphen "$debpkginstall"/opt/firefox/hyphenation

		# Use system certificates
		echo -e "Linking certificates"
		ln -sf /usr/lib/libnssckbi.so "$debpkginstall"/opt/firefox/libnssckbi.so

		sed -i 's/Version:.*/Version: '$pkgver/g "$debpkgdir"control
		cp control "$debpkginstall"/DEBIAN/

		sleep 2

		bannershow

		echo -e "Starting Debian PKGBUILD ..."
		echo ""
		sleep 1

		dpkg-deb --build --root-owner-group $debpkgname

		echo -e "PKG BUILD SUCCESSFUL"
		sleep 1
		bannershow
		echo -e "Cleaning BUILD environment ..."
		rm -rf $debpkginstall 
		echo ""
		echo -e "Removing the current Firefox"
		sudo apt remove *firefox* -y
		echo ""
		echo -e "Installing the previously built package"
		sleep 1
		sudo apt install ffmpeg hunspell pulseaudio -y
		bannershow
		sudo dpkg -i *.deb
		bannershow
		sudo apt-get install -f

			bannershow

			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "$Cyan│$nc $red[$green+$red]$green Installation Successful $red[$green+$red]$Cyan │$nc"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────┙$nc\n"

			echo -e "$Cyan╔─────────────────────────────────────────────────────────────────────────╗$nc"
			echo -e "If you Encouter a issue Please Report the issue to,"
			echo -e "https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/issues 😬"
			echo -e "$Cyan┖─────────────────────────────────────────────────────────────────────────┙$nc\n"
			
			xdotool key function+F11

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
			
			xdotool key function+F11

			exit 1
ƒ
fi
fi
