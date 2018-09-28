#!/bin/bash

f=$(which fastboot)

clear

## Opening statements
opnstmnt(){
echo "obliteratam's small modifications to:"
echo "Deuces-flash-all-script-V4.4-Linux"
echo "for Taimen & Walleye - Google Pixel 2 / XL"
echo "USE AT YOUR OWN RISK"
echo "THIS HAS NOT BEEN TESTED ON MAC / OSX"
read -n1 -r -p "Press any key to continue..." key
clear

echo "Make sure you've changed your working directory to the"
echo "directory where your archived factory image resides"
echo "Make sure the archive is the only archive in the directory."
echo "before you execute this script."
echo "There's no need to extract the archive yourself."
echo "The script will take care of that for you."
read -n1 -r -p "Press any key to continue..." key
clear

echo "Make Sure your Device is in Fastboot Mode"
echo "(Power off, hold Volume-Down, hold Power)"
echo "Once you are in fastboot,"
read -n1 -r -p "Press any key to continue..." key
clear
}

##Prep
#mkdir for .imgs and extract zipped images
prep(){
ls | grep *.zip > fldr.temp
sed 's/.zip//' fldr.temp
mkdir -pv $(cat fldr.temp)/images
unzip -d $(cat fldr.temp) $(cat fldr.temp).zip

pushd $(cat fldr.temp)
unzip -d images/ *.zip

pushd $PWD/images
# Get list of images
ls | grep *.img > images.temp
sed 's/system*//' images.temp
sed 's/.img//' images.temp
popd
popd
clear
}

##choices-Bootloader-Unlocking
unlkbtldr(){
read -p "Unlock Bootloader? (y/n)" answer
if echo "$answer" | grep -iq "^y" ;then
    echo "Running Unlock"
    echo "Look at your device,"
    echo "press up arrow and Power to confirm"
	sudo $f flashing unlock
    echo "This will say FAILED if already unlocked - ignore"
    sleep 5

    echo "Running Unlock_critical"
    echo "Look at your device,"
    echo "press up arrow and Power to confirm"
	sudo $f flashing unlock_critical
    echo "This will say FAILED if already unlocked, or if device=Walleye - ignore"
	sleep 5
else
    echo "Skipping unlock(s)"
fi
clear
}

## Flash bootloader and radio modem
flblr(){
pushd $(cat folder.temp)
echo "Flashing Bootloader & Radio A&B..."
sudo $f flash bootloader_a bootloader*.img
sudo $f reboot-bootloader
sleep 5
sudo $f flash bootloader_b bootloader*.img
sudo $f reboot-bootloader
sleep 5
sudo $f flash radio_a radio*.img
sudo $f reboot-bootloader
sleep 5
sudo $f flash radio_b radio*.img
sudo $f reboot-bootloader
sleep 5
popd
clear
}


## Flash images
flash(){
pushd $(cat fldr.temp)/images
# Flash Partition A
sudo $f --set-active=a
echo "Flashing Partition A..."
for i in $(cat images.temp); do
    sudo $f flash "$i"_a "$i".img;
done
sudo flash $f system_a system.img

# Flash Partition B
sudo $f --set-active=b
echo "Flashing partition B..."
for i in $(cat images.temp); do
    sudo $f flash "$i"_b "$i".img
done
sudo $f flash system_b system_other.img

sudo $f --set-active=a
rm -v images.temp
popd
clear
}

rmfldrtemp(){
rm fldr.temp
}

## Format user data prompt
frmtdt(){
echo -n "FORMAT USERDATA? (y/n)"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo "Wiping UserData.."
    sudo $f format userdata
else
    echo "Not wiping..."
fi
echo "Finished Flashing... if you are still having bootloops, you may need to format userdata in factory recovery"
echo "DO NOT LOCK THE BOOTLOADER UNLESS YOU ARE SURE IT IS OPERATING PROPERLY"
}

## Reboot system prompt
rbtsys(){
read -p "Reboot system? Enter [y/N]" cont
case $cont in
	[Yy*]) echo Rebooting to system...
		sudo $f continue
		;;
	[Nn*]) echo "Staying in fastboot mode..."
		;;
esac
}

#####################
# The whole shebang #
#####################
opnstmnt
prep
unlkbtldr
flblr
flash
rmfldrtemp
frmtdt
rbtsys