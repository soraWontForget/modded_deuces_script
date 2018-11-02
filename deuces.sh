#!/bin/bash

##########################
# DOWNLOAD FACTORY IMAGE #
##########################

#####################
# UNLOCK BOOTLOADER #
#####################

unlockBootloader()
{
    
    echo -en "\n"
    echo -en "\n"
    read -p "Have you unlocked the Bootloader? (y/n)" answer
    if echo "$answer" | grep -iq "^y"; then
        echo "If your device is already unlocked, or your device is a Pixel 2/'walleye', a failure message will appear."
        echo -en "\n"
        echo -en "\n"
        sleep 2;
        echo "On your device:"
        echo "1. Press the up arrow and power button to confirm"
        sleep 2;
        sudo $(which fastboot) flashing unlock
        sleep 7;

        echo "Again, on your device: "
        echo "1. Press up arrow and power button to confirm"
        sudo $(which fastboot) flashing unlock_critical
        sleep 5
    else
        echo -en "\n"
        echo -en "\n"
        echo "Skipping unlock(s)"
    fi

}

###################
# LOCK BOOTLOADER #
###################

#########################
#  FLASH FACTORY IMAGE  #
#########################

flash()
{

    ## Opening statements
    openingStatement(){
        echo -en "\n"
        echo -en "\n"
        echo "If you haven't done so already, put your device into fastboot mode by:"
        echo "1. Powering off your device"
        echo "2. Hold the power button and volume down buttons until the device starts fastboot mode."
        read -n1 -r -p "Press any enter to continue..." key
        echo -en "\n"
        echo -en "\n"

    }


    ##Prep
    #mkdir for .imgs and extract zipped images to new dir
    prep()
    {

        archive=$(ls | grep *.zip)
        newFolderDirectory=$(ls | grep *.zip | sed 's/-factory.*//g')

        echo -en "\n"
        echo -en "\n"
        unzip $archive */bootloader* */image* */radio*
        pushd $newFolderDirectory
            mkdir images/
            unzip *.zip -x android-info.txt -d images/
            images=$(ls images/ | sed 's/system*.*//' | sed '/^$/d') # Get list of images
        popd

    }

    ## Flash bootloader and radio modem
    flashBootloaderAndRadio()
    {

        pushd $newFolderDirectory
            echo -en "\n"
            echo -en "\n"
            echo "If the script hangs at:"
            echo "'< waiting for any device >'"
            echo "Unplug your device from your usb cable,"
            echo "then plug the usb back in."
            echo -en "\n"
            read -n 1 -r -p "Press enter to continue." key
            echo -en "\n"
            echo -en "\n"
            echo "Flashing Bootloader & Radio A&B..."

            setActiveSlotA
            sleep 1;
            sudo $(which fastboot) flash bootloader_a bootloader*.img
            sleep 1;
            sudo $(which fastboot) reboot-bootloader
            sleep 1;
            sudo $(which fastboot) flash radio_a radio*.img
            sleep 1;
            sudo $(which fastboot) reboot-bootloader
            sleep 1;
            echo -en "\n"
            echo -en "\n"

            setActiveSlotB
            sleep 1;
            sudo $(which fastboot) flash bootloader_b bootloader*.img
            sleep 1;
            sudo $(which fastboot) reboot-bootloader
            sleep 1;
            sudo $(which fastboot) flash radio_b radio*.img
            sleep 1;
            sudo $(which fastboot) reboot-bootloader
            echo -en "\n"
            echo -en "\n"
        popd

    }


    ## Flash images
    flashPartitions()
    {

        # Flash Partition A
        echo -en "\n"
        echo -en "\n"
        echo "Flashing Partition A..."

        setActiveSlotA
        sleep 1;
        for i in $images; do
            sudo $(which fastboot) flash $(echo $i | sed 's/.img//')_a $newFolderDirectory/images/$i;
            sleep 2;
        done
        sleep 2;
        sudo $(which fastboot) flash system_a $newFolderDirectory/images/system.img;

        # Flash Partition B
        echo -en "\n"
        echo -en "\n"
        echo "Flashing partition B..."
        setActiveSlotB
        sleep 1;
        for i in $images; do
            sudo $(which fastboot) flash $( echo $i | sed 's/.img//' )_b $newFolderDirectory/images/$i;
            sleep 2;
        done
        sleep 2;
        sudo $(which fastboot) flash system_b $newFolderDirectory/images/system_other.img;

    }

    ## Set the active boot partitions
    # Set active partition A
    setActiveSlotA()
    {

        sudo $(which fastboot) --set-active=a

    }

    # Set active partition B
    setActiveSlotB()
    {

    sudo $(which fastboot) --set-active=b

    }

    ## Format user data prompt
    formatUserData()
    {

        echo -en "\n"
        echo -en "\n"
        read -p "FORMAT USERDATA? (y/n)" answer
        if echo "$answer" | grep -iq "^y" ;then
            echo "Wiping UserData.."
            sudo $(which fastboot) format userdata
        else
            echo "Not wiping..."
        fi
        echo "Finished Flashing... if you are still having bootloops, you may need to format userdata in factory recovery"
        echo "DO NOT LOCK THE BOOTLOADER UNLESS YOU ARE SURE IT IS OPERATING PROPERLY"

    }

    ## Reboot system prompt
    rebootSystemPrompt()
    {

        echo -en "\n"
        echo -en "\n"
        read -p "Reboot system? Enter (y/N)" cont
        case $cont in
            [Yy*]) echo Rebooting to system...
                sudo $(which fastboot) continue
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
    flashBootloaderAndRadio
    flashPartitions
    setActiveSlotA
    formatUserData
    rebootSystemPrompt
}


################
# INSTALL TWRP #
################

installTwrp()
{



read -p "You chose to install TWRP. Is this what you really wanted to do? (y/n)" answer

if echo "$answer" | grep -iq "^y"; then
    echo "Would you like to install by:"
    echo "1. adb sideload"
    echo "2. Booting into TWRP with TWRP img"
    read -p "Enter choice: " answer

    if [ $answer == 1 ]; then

        twrpInstallationZipDirectory = /home/sora/placeholder
        twrpInstallationZipPlaceHolder = /home/sora/placeholder.zip

        clear
        echo "If you haven't done so already, put your device into recovery mode by:"
        echo "1. Powering off your device"
        echo "2. Hold the power button and volume down buttons until the device starts fastboot mode."
        echo "3. Press either up or down on the volume button repeatedly until the 'Recovery mode' option appears."
        echo -en "\n"
        read -n1 -r -p "Press any enter to continue..." key

        echo "Next, have your device plugged in to your computer."
        echo "Select the 'adb sideload' menu option on your device by using the volume and power buttons."
        echo -en "\n"
        read -n1 -r -p "Press any enter to continue..." key
        clear
        echo "Installing TWRP..."
        sleep 1;
        pushd $twrpInstallationZipDirectory
            sudo adb sideload $twrpInstalllationZipPlaceholder
        popd
        sleep 1;
        echo -en "\n"
        echo "Finished!"
        echo -en "\n"
        echo -en "\n"
        echo "Is that all you wanted to do? (y/n)"
        choice=5

            if echo "$answer" | grep -iq "^y"; then

                echo "Bye!"
                $choice = 12

            else

                read -n1 -r -p "Press any enter to return to the menu" key
                $choice = 0
            fi
    else

        echo -en "\n"
        echo "If you haven't done so already, put your device into fastboot mode by:"
        echo "1. Powering off your device"
        echo "2. Hold the power button and volume down buttons until the device starts fastboot mode."
        read -n1 -r -p "Press enter to continue..." key
        echo "Booting into TWRP with TWRP boot img."
        read -n1 -r -p "Press enter to continue..." key
        pushd [place holder twrpBootImgPath]
            sudo $(which fastboot) boot [twrp img]
        popd
    fi

fi
}

##################
# UNINSTALL TWRP #
##################

#########################
# INSTALL CUSTOM KERNEL #
#########################

###########################
# UNINSTALL CUSTOM KERNEL #
###########################

###############
# ENABLE ROOT #
###############

################
# DISABLE ROOT #
################


menu()
{

    echo "Hey there, $(whoami)!"
    echo "Choose what you'd like to do:"
    echo -en "\n"
    echo "1. Download Factory Image"
    echo "2. Flash Factory Image"
    echo "3. Unlock Bootloader"
    echo "4. Lock Bootloader"
    echo "5. Install: TWRP"
    echo "6. Uninstall: TWRP"
    echo "7. Install Custom Kernel"
    echo "8. Uninstall Custom Kernel"
    echo "9. Enable Root Access"
    echo "10. Disable Root Access"
    echo "11. All-in-one bootloader unlock, TWRP installation (optional), custom kernel installation (optional), and enable root access"
    echo "12. Quit"
    read -p "Enter your choice: " choice

}

choice = 0;
while [[ $choice != 12 ]] ; do

    menu
    if [ $choice == 1 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 2 ]; then
        flash

    elif [ $choice == 3 ]; then
        unlockBootloader

    elif [ $choice == 4 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 5 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 6 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 7 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 8 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 9 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 10 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'

    elif [ $choice == 11 ]; then
        echo "Not available yet!"
        echo -en '\n'
        echo -en '\n'
        echo -en '\n'
    elif [ $choice == 12 ]; then
        echo -en '\n'
        echo -en '\n'
        echo "Bye!"
    fi
done


