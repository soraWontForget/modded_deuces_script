#!/bin/bash

f=$(which fastboot)



## Opening statements
openingStatement(){
echo -en "\n"
echo -en "\n"
echo "soraWontForget's small modifications to:"
echo "Deuces-flash-all-script-V4.4-Linux"
echo "for Taimen & Walleye - Google Pixel 2 / XL"
echo "USE AT YOUR OWN RISK"
echo "THIS HAS NOT BEEN TESTED ON MAC / OSX"
read -n1 -r -p "Press any key to continue..." key
echo -en "\n"
echo -en "\n"

echo -en "\n"
echo -en "\n"
echo "Make sure you've changed your working directory to the"
echo "directory where your archived factory image resides"
echo "Make sure the archive is the only archive in the directory."
echo "before you execute this script."
echo "There's no need to extract the archive yourself."
echo "The script will take care of that for you."
read -n1 -r -p "Press any key to continue..." key
echo -en "\n"
echo -en "\n"

echo -en "\n"
echo -en "\n"
echo "Make sure your device is in Fastboot Mode"
echo "(Power off, hold Volume-Down, hold Power)"
echo "Once you are in fastboot,"
read -n1 -r -p "Press any key to continue..." key
echo -en "\n"
echo -en "\n"
}

##Prep
#mkdir for .imgs and extract zipped images
prep(){
archive=$(ls | grep *.zip)
newFolderDirectory=$(ls | grep *.zip | sed 's/-factory.*//')

echo -en "\n"
echo -en "\n"
unzip $archive */bootloader* */image* */radio*
pushd $newFolderDirectory
    mkdir images/
    unzip *.zip -x android-info.txt -d images/
    # Get list of images
    images=$(ls images/ | sed 's/system*.*//' | sed '/^$/d')
popd
}

##choices-Bootloader-Unlocking
unlockBootloader(){
echo -en "\n"
echo -en "\n"
read -p "Unlock Bootloader? (y/n)" answer
if echo "$answer" | grep -iq "^y" ;then
    echo -en "\n"
    echo -en "\n"
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
    echo -en "\n"
    echo -en "\n"
    echo "Skipping unlock(s)"
fi
}

## Flash bootloader and radio modem
flashBootloaderAndRadio(){
pushd $newFolderDirectory
    echo -en "\n"
    echo -en "\n"
    echo "If the script hangs at:"
    echo "'< waiting for any device >'"
    echo "Unplug your device from your usb cable,"
    echo "and then plug it back in."
    echo -en "\n"
    read -n 1 -r -p "Press enter to continue." key
    echo -en "\n"
    echo -en "\n"
    echo "Flashing Bootloader & Radio A&B..."

    setActiveSlotA
    sudo $f flash bootloader_a bootloader*.img
    sudo $f reboot-bootloader
    sleep 1;
    sudo $f flash radio_a radio*.img
    sudo $f reboot-bootloader
    echo -en "\n"
    echo -en "\n"

    setActiveSlotB
    sleep 1;
    sudo $f flash bootloader_b bootloader*.img
    sudo $f reboot-bootloader
    sleep 1;
    sudo $f flash radio_b radio*.img
    sudo $f reboot-bootloader
    echo -en "\n"
    echo -en "\n"
popd

}


## Flash images
flashPartitions(){
# Flash Partition A
echo -en "\n"
echo -en "\n"
echo "Flashing Partition A..."

setActiveSlotA
sleep 1;
for i in $images; do
    sudo $f flash $( echo $i | sed 's/.img//' )_a $newFolderDirectory/images/$i;
    sleep 2;
done
sleep 2;
sudo $f flash system_a $newFolderDirectory/images/system.img;

# Flash Partition B
echo -en "\n"
echo -en "\n"
echo "Flashing partition B..."
setActiveSlotB
sleep 1;
for i in $images; do
    sudo $f flash $( echo $i | sed 's/.img//' )_b $newFolderDirectory/images/$i;
    sleep 2;
done
sleep 2;
sudo $f flash system_b $newFolderDirectory/images/system_other.img;
}

## Set the active boot partitions
# Set active partition A
setActiveSlotA(){
sudo $f --set-active=a
}

# Set active partition B
setActiveSlotB(){
sudo $f --set-active=b
}

## Format user data prompt
formatUserData(){
echo -en "\n"
echo -en "\n"
read -p "FORMAT USERDATA? (y/n)" answer
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
rebootSystemPrompt(){
echo -en "\n"
echo -en "\n"
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
openingStatement
prep
unlockBootloader
flashBootloaderAndRadio
flashPartitions
setActiveSlotA
formatUserData
rebootSystemPrompt
