#!/bin/bash

# This script will attempt to install/uninstall the following software:
# GNS3 Network Simulator
# Dynamips Router Firmware Emulator
# VPCs Virtual PC Emulator

# As of this time only Ubunutu 14.04 ( or trusty derivatives ) are accepted.
# If your distro uses apt package manager, and you want to attempt to use the script, you need
# to edit the script. To do this run "lsb_release -a 2>/dev/null | grep Codename | cut -f2"
# in your terminal and then replace "trusty" ( on line 423 ) with the output from the command.
# Absolutely no guarantees it will work though.

#-----------------------------------------------------------------#
#-----------------------------------------------------------------#
#---###########################################################---#
#---##################### Functions Start #####################---#
#---###########################################################---#
#-----------------------------------------------------------------#
#-----------------------------------------------------------------#


#-----------------------------------------------------------------#

###################################################################
####################### Installer Functions #######################
############################# START ###############################
###################################################################

#-----------------------------------------------------------------#


# Dynamips installer function
function dynamips_install {
	cd /tmp/gns3/GNS3*.source/dynamips*
	mkdir build ; cd build
	cmake ..
	make
	echo -e "\e[31m****** Installing Dynamips ******\e[0m "
	sudo make install
	echo
	# Send System Notification
	notify-send -t 4000 -u low -i $working_directory/dyn.png "Dynamips Installed"
	echo -e "\e[32m****** Dynamips installed ******\e[0m "
	echo
}

# GNS3 Server installer function
function gns3_srv_install {
	cd /tmp/gns3/GNS3*.source/gns3-server*
	echo -e "\e[31m****** Installing GNS Server ******\e[0m "
	sudo python3 setup.py install
	echo
	echo -e "\e[32m****** GNS3 Server installed ******\e[0m "
}

# GUI install function
function gns3_gui_install {
	cd /tmp/gns3/GNS3*.source/gns3-gui*
	echo
	echo -e "\e[31m****** Installing GNS GUI ******\e[0m "
	sudo python3 setup.py install
	echo
	# Send System Notification
	notify-send -t 4000 -u low -i $working_directory/gns3.png "GNS3 Installed"
	echo -e "\e[32m****** GNS3 GUI installed ******\e[0m "
	echo
}

# Function to create the desktop icon for gns3
function create_icon {
	text="[Desktop Entry]\n
	Name=GNS3\n
	Comment=Graphical Network Simulator\n
	Keywords=network;simulator\n
	Exec=/usr/local/bin/gns3\n
	Icon=/usr/share/applications/gns3.png\n
	Terminal=false\n
	Type=Application\n
	StartupNotify=true\n
	Categories=Development"

	echo -e "\e[31m****** Creating an Application Icon for GNS3 ******\e[0m "
	echo
	sudo cp $working_directory/gns3.png /usr/share/applications
	echo -e $text > $working_directory/gns3.desktop && sudo mv $working_directory/gns3.desktop /usr/share/applications
	# Give the file the proper permissions
	sudo chmod u+x /usr/share/applications/gns3.desktop
	echo -e "\e[32m****** All Done ******\e[0m "
	echo
}

# VPCS Installer function
function vpcs_install {
	cd /tmp/gns3/GNS3*.source/vpcs*/src
	echo -e "\e[31m****** Attempting to install VPCS ******\e[0m "
	echo
	if [ "$architecture" = "x86_64" ];then
		echo -e "\e[34m****** 64 Bit Install ******\e[0m "
		echo $(sudo ./mk.sh 64)
	else
		echo -e "\e[34m****** 32 Bit Install ******\e[0m "
		echo $(sudo ./mk.sh 32 )
	fi

	# Copy the binary to /usr/bin
	sudo cp vpcs /usr/bin
	# Send System Notification
	notify-send -t 4000 -u low -i $working_directory/vpcs.png "VPCS Installed"
	echo -e "\e[93m****** Virtual PC is installed ******\e[0m "
	echo
	echo -e "\e[93m*** You can execute it from terminal by typing 'vpcs' and hitting enter ***\e[0m "
	echo
}




#-----------------------------------------------------------------#

###################################################################
####################### Installer Functions #######################
############################## END ################################
###################################################################

#-----------------------------------------------------------------#
#-----------------------------------------------------------------#

###################################################################
##################### Uninstaller Functions #######################
############################ START ################################
###################################################################

#-----------------------------------------------------------------#


function gns3_uninstall {
	gns3=$(which gns3)
	pip3=$(which pip3)
	
	# As long as GNS3 is installed, download and install Pip for the removal procedure
	if [[ -z "$pip3" && -n "$gns3" ]]; then
		echo -e "\e[32m*** Installing Pip ***\e[0m"
		echo
		sleep 1
		# Use pip to uninstall package; Note that pip needs to be upgraded to latest release to work properly
		sudo apt-get update && sudo apt-get install -y python3-pip && sudo easy_install3 -U pip
		echo
		echo -e "\e[32m*** Continuing ***\e[0m"
	fi
	
	# If GNS 3 is installed, continue. Otherwise exit
	if [[ -n "$gns3" ]]; then
		echo -e "\e[31m*** Removing GNS3 ***\e[0m"
		# Uninstall GNS3
		sudo -H pip3 uninstall -y gns3-server 2>/dev/null
		sudo -H pip3 uninstall -y gns3-gui 2>/dev/null
		sudo -H pip3 uninstall -y gns3-converter 2>/dev/null
		sudo -H pip3 uninstall -y gns3dms gnsserver 2>/dev/null
		# Remove unwanted files associated with GNS3
		sudo rm /usr/local/bin/gns3
		sudo rm -r ~/GNS3 2>/dev/null
		sudo rm -r ~/.config/GNS3 2>/dev/null
		sudo rm -r /usr/local/lib/python3.4/dist-packages/gns3*.egg 2>/dev/null
		sudo rm /usr/share/app-install/icons/gns3.png 2>/dev/null
		sudo rm /usr/share/app-install/desktop/gns3:gns3.desktop 2>/dev/null
		echo
		echo -e "\e[32m*** Uninstall GNS3 Complete ***\e[0m"
		echo
		# Remove the desktop entry and icon file
		echo -e "\e[31m*** Removing Desktop Shortcut! ***\e[0m"
		echo
		sudo rm /usr/share/applications/gns3.desktop
		sudo rm /usr/share/applications/gns3.png
		echo -e "\e[32m*** Done ***\e[0m"
		notify-send -t 4000 -u low "GNS3 Uninstall Complete"; sleep 1
		echo
	else
		echo -e "\e[31m*** Nothing to Uninstall ***\e[0m"
	fi
}

function dyn_uninstall {
	dyn=$(which dynamips)
	
	# If Dynamips is installed, continue. Otherwise exit
	if [[ -n "$dyn" ]]; then
		# Remove the Dynamips binary and associated files/folders
		echo -e "\e[31m*** Removing Dynamips ***\e[0m"
		echo
		sudo rm /usr/local/bin/dynamips
		sudo rm -r /usr/local/share/doc/dynamips
		sudo rm /usr/local/share/man/man1/dynamips.1
		echo -e "\e[32m*** All Done ***\e[0m"
		sleep 1
		echo -e "\e[32m***  Exiting  ***\e[0m"
		notify-send -t 4000 -u low "Dynamips Uninstall Complete"; sleep 1
		echo
	else 	
		echo -e "\e[31m*** Nothing to Uninstall ***\e[0m"
	fi
}


function vpcs_uninstall {
	vpcs=$(which vpcs)

	# If VPCS is installed, continue. Otherwise exit
	if [[ -n "$vpcs" ]]; then
		# Remove the VPCS binary
		echo -e "\e[31m*** Removing VPCS ***\e[0m"
		sudo rm /usr/bin/vpcs
		echo
		echo -e "\e[32m** Done ***\e[0m"
		notify-send -t 4000 -u low "VPCS Uninstall Complete"; sleep 1
		echo
	else
		echo -e "\e[31m*** Nothing to Uninstall ***\e[0m"
	fi
}


#-----------------------------------------------------------------#

###################################################################
##################### Uninstaller Functions #######################
############################# END #################################
###################################################################

#-----------------------------------------------------------------#
#-----------------------------------------------------------------#

###################################################################
############## Clean up and verification functions ################
###################################################################

#-----------------------------------------------------------------#


# Clean up function
function clean_up {
	cd
	echo -e "\e[31m****** House Cleaning! ******\e[0m "
	echo
	sudo rm -R /tmp/gns3
	# Send System Notification
	notify-send -t 5000 -u low "Cleanup Complete"
}

# Detects if the software has been installed correctly.
function sw_check {
	# Check for GNS3
	gns=$(which gns3)
	gns_exit=$?
	if [ -n "$gns" ]; then
		echo -e "\e[32m****** GNS3 Install Successful! ******\e[0m ";echo
		echo -e "\e[31m*** Exit status of command is $gns_exit\e[0m";echo
	else
		echo -e "\e[31mError, gns value = $gns\e[0m ";echo
		echo -e "\e[31m*** Exit status of command is $gns_exit\e[0m";echo
	fi

	# Check for VPCS
	vpc=$(which vpcs)
	vpcs_exit=$?
	if [ -n "$vpc" ]; then
		echo -e "\e[32m****** VPCS Install Successful! ******\e[0m ";echo
		echo -e "\e[31m*** Exit status of command is $vpcs_exit\e[0m";echo
	else
		echo -e "\e[31mError, vpcs value = $vpc\e[0m ";echo
		echo -e "\e[31m*** Exit status of command is $vpcs_exit\e[0m";echo
	fi

	# Checks for Dynamips
	dmips=$(which dynamips)
	dyn_exit=$?
	if [ -n "$dmips" ]; then
		echo -e "\e[32m****** Dynamips Install Successful! ******\e[0m ";echo
		echo -e "\e[31m*** Exit status of command is $dyn_exit\e[0m";echo
	else
		echo -e "\e[31mError, dynamips value = $dmips\e[0m ";echo
		echo -e "\e[31m*** Exit status of command is $dyn_exit\e[0m";echo
	fi
}

#-----------------------------------------------------------------#

###################################################################
######################### Exit Function ###########################
###################################################################

#-----------------------------------------------------------------#


function script_exit {
	echo -e "\e[31m*** Don't forget to remove the Working Directory as it is no longer needed! ***\e[0m"
	echo
	end=$(date +%s)
	runtime=$(($end-$start))
	echo -e "\e[32m****** Total Runtime is "$runtime" sec's ******\e[0m"
	echo
	echo -e "\e[31m****** Exiting from the script! ******\e[0m "
	exit 0
}


#-----------------------------------------------------------------#

#---###########################################################---#
#---##################### Functions END #######################---#
#---###########################################################---#

#-----------------------------------------------------------------#



#-----------------------------------------------------------------#
#------------------------################-------------------------#
#---#####################----------------######################---#
#---#####################   Begin Main   ######################---#
#---#####################----------------######################---#
#------------------------################-------------------------#
#-----------------------------------------------------------------#


#-----------------------------------------------------------------#

###################################################################
#################### Check For Arguments ##########################
###################################################################

#-----------------------------------------------------------------#


# Check for arguments, "U" switch will call the uninstaller if found
# If there are no arguments then continue with the installer

if [ "$#" -eq 0 ]; then
	echo -e "\e[32m*** No arguments ***\e[0m"
	# Set the start time
	start=$(date +%s)

# Otherwise an argument was passed, process the argument
else
	# If the argument is equal to U then run the uninstaller menu
	if [ "$1" = "-U" ]; then	
		while true;
		do
			echo "Choose which packages you wish to remove :"
			echo "[A]ll" echo
			echo "[D]ynamips" echo
			echo "[V]pcs" echo
			echo "[G]NS3" echo
			echo "[Q]uit" echo
			read choice
			
			# Match the response through case
			case $choice in 

				[Aa])   # If user chooses All
					start=$(date +%s)
					gns3_uninstall
					dyn_uninstall
					vpcs_uninstall
					end=$(date +%s)
					runtime=$(($end-$start))
					exit 0
				;;
				[Dd])   # If user chooses Dynampis
					start=$(date +%s)
					dyn_uninstall
					end=$(date +%s)
					runtime=$(($end-$start))
					continue
				;;
				[Vv])   # If user chooses VPCS
					start=$(date +%s)
					vpcs_uninstall
					end=$(date +%s)
					runtime=$(($end-$start))
					continue
				;;
				[Gg])   # If user chooses GNS3
					start=$(date +%s)
					gns3_uninstall
					end=$(date +%s)
					runtime=$(($end-$start))
					continue
				;;
				[Qq])   # If user chooses Quit
					exit 0
				;;
				*)
					echo "Invalid Entry"
				;;
			# Close the case statement			
			esac
		# Close the while loop
		done
	else
		echo "Error, Invalid Argument "$1" "
		exit 2			
	fi
fi


#-----------------------------------------------------------------#

###################################################################
########################## Check System ###########################
########################## Requirements ###########################
###################################################################

#-----------------------------------------------------------------#


distro=$(lsb_release -a 2>/dev/null | grep Codename | cut -f2)
echo $distro
# If it doesn't match requirements display error
if [[ "$distro" != *"trusty"* ]]; then
	echo -e "\e[31m********* Error, Wrong Distro **********\e[0m "
	sleep 1
	echo 
	echo -e "\e[31m****** Quitting script! ******\e[0m "
	echo
	end=$(date +%s)
	runtime=$(($end-$start))
	echo -e "\e[32m****** Total Runtime is "$runtime" sec's ******\e[0m"
	exit 2
fi

# Is it 32/64 bit?
architecture=$(arch)

# Find out which directory we are working from
working_directory=$PWD


#-----------------------------------------------------------------#

###################################################################
####### Create a working directory & download the source ##########
###################################################################

#-----------------------------------------------------------------#


# Create a temporary working directory and cd into it
mkdir /tmp/gns3/ 2>/dev/null
cd /tmp/gns3

# Download the required files
echo -e "\e[31mDownloading Files!\e[0m "
wget http://downloads.gns3.com/GNS3-1.2.3.source.zip -O gns.zip
echo
echo -e "\e[31mInitial download complete\e[0m"
echo

# Extract the main archive
unzip gns.zip
# Once extracted there is no need for the original zipfile, move to trash
rm gns.zip

# Change directory to the newly created and extract all the zipfiles
cd GNS3*.source
unzip "*.zip"
rm *.zip


#-----------------------------------------------------------------#

###################################################################
###################### Install Dependencies #######################
###################################################################

#-----------------------------------------------------------------#


# Request permission to continue installing packages
echo -e "\e[31mThe script needs to install dependencies\e[0m "
echo

# While loop to input and validate the response
while true; do

	# Ask to install dependencies
	echo -en "\e[31mEnter\e[0m \e[32myes\e[0m \e[31mto\e[0m \e[32mcontinue\e[0m \e[31mor\e[0m \e[93mno\e[0m \e[31mto\e[0m \e[93mquit : \e[0m "
	read response

	# Match the response through case
	case $response in
		
		[yY] | [yY][Ee][Ss])   # If YES/yes
			echo "Continuing"
			echo -e "\e[31mInstalling Packages, please be patient!\e[0m "

			# Make sure to run apt-get update !
			sudo apt-get update
			# Install requirements, use Y switch to default to yes at prompt!
			sudo apt-get install -y python3 libpcap-dev uuid-dev libelf-dev cmake python3-setuptools python3-pyqt4 python3-ws4py python3-zmq python3-tornado
			sudo apt-get install -y python3-netifaces
			echo
			echo -e "\e[32m****** All done installing packages ******\e[0m "
			echo
			break
		;;

		# If NO/no
		[nN] | [nN][Oo])
			echo "Exiting Script"
			cd
			rm -R /tmp/gns3/GNS3-1.2.3.source
			echo -e "\e[31mFolder removed\e[0m "
			echo
			end=$(date +%s)
			runtime=$(($end-$start))
			echo -e "\e[32m****** Total Runtime is "$runtime" sec's ******\e[0m"
			exit 0
		;;

		# Anything else is invalid, repeat menu.
		*)
			echo "Invalid Input"
		;;
	# Close the case statement
	esac
# Close the while loop
done


#-----------------------------------------------------------------#

###################################################################
#################### Call the Installer Functions #################
###################################################################

#-----------------------------------------------------------------#


# Array to hold the function calls
declare -a progs=( 'dynamips_install' 'vpcs_install' 'gns3_srv_install' 'gns3_gui_install' 'create_icon' 'clean_up' 'sw_check' 'script_exit' )

# For loop to process the functions
for i in "${progs[@]}"; do
	$i
done


#-----------------------------------------------------------------#
#------------------------################-------------------------#
#---#####################----------------######################---#
#---#####################    End Main    ######################---#
#---#####################----------------######################---#
#------------------------################-------------------------#
#-----------------------------------------------------------------#
