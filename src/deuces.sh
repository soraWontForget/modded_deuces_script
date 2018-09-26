#!/bin/bash

clear
echo "obliteratam's small modifications to:"
echo "Deuces-flash-all-script-V4.4-Linux"
echo "for Taimen & Walleye - Google Pixel 2 / XL"
echo "USE AT YOUR OWN RISK"
echo "THIS HAS NOT BEEN TESTED ON MAC / OSX"
read -n1 -r -p "Press any key to continue..." key

echo "Make Sure your Device is in Fastboot Mode"
echo "(Power off, hold Volume-Down, hold Power)"
echo "Once you are in fastboot,"
read -n1 -r -p "Press any key to continue..." key
clear
##choices-Bootloader-Unlocking

f=$(which fastboot)

echo -n "Unlock Bootloader? (y/n)"
read answer
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

echo "Flashing Bootloader & Radio A&B"
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

echo "Flashing All Others -- Without Reboot"
sudo $f --set-active=a

##Flashing Slot A
sudo $f flash abl_a abl.img
sudo $f flash aes_a aes.img
sudo $f flash apdp_a apdp.img
sudo $f flash boot_a boot.img
sudo $f flash cmnlib_a cmnlib.img
sudo $f flash cmnlib64_a cmnlib64.img
sudo $f flash devcfg_a devcfg.img
sudo $f flash dtbo_a dtbo.img
sudo $f flash hyp_a hyp.img
sudo $f flash keymaster_a keymaster.img
sudo $f flash laf_a laf.img
sudo $f flash modem_a modem.img
sudo $f flash msadp_a msadp.img
sudo $f flash pmic_a pmic.img
sudo $f flash rpm_a rpm.img
sudo $f flash tz_a tz.img
sudo $f flash vbmeta_a vbmeta.img
sudo $f flash vendor_a vendor.img
sudo $f flash xbl_a xbl.img

echo "Flashing System A"
sudo $f flash system_a system.img
echo "Flashing System B"
sudo $f flash system_b system_other.img

##Flashing Slot B
sudo $f --set-active=b
sudo $f flash abl_b abl.img
sudo $f flash aes_b aes.img
sudo $f flash apdp_b apdp.img
sudo $f flash boot_b boot.img
sudo $f flash cmnlib_b cmnlib.img
sudo $f flash cmnlib64_b cmnlib64.img
sudo $f flash devcfg_b devcfg.img
sudo $f flash dtbo_b dtbo.img
sudo $f flash hyp_b hyp.img
sudo $f flash keymaster_b keymaster.img
sudo $f flash laf_b laf.img
sudo $f flash modem_b modem.img
sudo $f flash msadp_b msadp.img
sudo $f flash pmic_b pmic.img
sudo $f flash rpm_b rpm.img
sudo $f flash tz_b tz.img
sudo $f flash vbmeta_b vbmeta.img
sudo $f flash vendor_b vendor.img
sudo $f flash xbl_b xbl.img

sudo $f --set-active=a

##choices-format-relocks

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


read -p "Reboot system? Enter [y/N]" cont
case $cont in
	[Yy*]) echo Rebooting to system...
		sudo $f continue
		;;
	[Nn*]) echo "ok..."
		;;
esac
