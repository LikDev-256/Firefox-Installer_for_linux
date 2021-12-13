# Firefox-Installer && Updater
A Script that Installs and keeps your browser upto-date in Debian & Arch based systems. Which don't have the latest versions in the package manager.

---

## Firefox Installer
![Firefox installer script](https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/blob/main/Logos/firefox-installer.png)

#### ⚠️ This is not an official installer provided by Mozilla 

<*> This script currently supports the installation of **Firefox Beta**

---
## Getting Started
---
## Usage

1. Install git, Some distros doesn't require this step,

Debian Based,
```
sudo apt-get update
sudo apt-get install git
```
Arch Based,
```
sudo pacman-mirrors --fasttrack && sudo pacman -Syu
sudo pacman -S git
```

2. Running the script for installing Firefox,
```
cd ~/ && git clone https://github.com/LikDev-256/Firefox-Installer_Updater.git && cd ~/Firefox-Installer_Firefox-Updater && chmod +x firefox-installer.sh && ./firefox-installer.sh
```
---

## Testings

<table>
<thead>
<tr>
<th></th>
<th>Ubuntu</th>
<th>Debian</th>
<th>Garuda and arch based</th>
</tr>
</thead>
<tbody>
<tr>
<td>Installation worked!</td>
<td> ❎ Not Tested (Implemented)</td>
<td> ✔️ Tested Worked </td>
<td> ✔️ Tested Worked </td>
</tbody>
</table>

---
Needed help and contribution for testing
## **Please report any issues to the issues in github**
---------------------------------------------------------

Features to implement,
- [ ] Add options to the script
- [ ] Add a resume feature
- [ ] Make it fail proof
- [ ] Optimizations

# Firefox Updater

![Firefox updater script](https://github.com/LikDev-256/Firefox-Installer_Firefox-Updater/blob/main/Logos/firefox-updater.png)

## This script is still under development

The installer can be also used to update when the default update **Help >> About Firefox** doesn't work
