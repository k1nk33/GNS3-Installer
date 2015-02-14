#!/bin/bash

# This script will attempt to install the following software:
# GNS3 Network Simulator
# Dynamips Router Firmware Emulator
# VPCs Virtual PC Emulator

# As of this time only Ubunutu 14.04 ( or derivatives ) are accepted.

###################################################################
###################### Check Requirements #########################
###################################################################

distro=$(lsb_release -a 2>/dev/null | grep Description | cut -f2)
echo $distro
# If it doesn't match requirements display error
if [ "$distro" != "Ubuntu 14.04.1 LTS" ];then ###&& [ "$distro" != "Ubuntu 12.04.5 LTS" ];then
	echo -e "\e[31m********* Error, Wrong Distro **********\e[0m "
	sleep 1
	echo # blank line
	echo -e "\e[31m****** Quitting script! ******\e[0m "
	exit 0
fi

# Is it 32/64 bit?
architecture=$(arch)

# Find out which directory we are working from
working_directory=$PWD

###################################################################
####### Create a working directory & download the source ##########
###################################################################

# Create a temporary working directory and cd into it
mkdir /tmp/gns3/ 2>/dev/null
cd /tmp/gns3

# Download the required files
echo -e "\e[31mDownloading Files!\e[0m "
sleep 2
wget http://downloads.gns3.com/GNS3-1.2.3.source.zip -O gns.zip
echo
echo -e "\e[31mInitial download complete\e[0m"
sleep 2
echo

# Extract the main archive
unzip gns.zip
# Once extracted there is no need for the original zipfile, move to trash
rm gns.zip

# Change directory to the newly created and extract all the zipfiles
cd GNS3*.source
unzip "*.zip"
rm *.zip

# At this point the files are extracted to their respective folders

echo
echo -e "\e[31mThe script needs to install dependencies\e[0m "
echo
echo -en "\e[31mEnter\e[0m \e[32myes\e[0m \e[31mto\e[0m \e[32mcontinue\e[0m \e[31mor\e[0m \e[32mno\e[0m \e[31mto\e[0m \e[32mquit : \e[0m "
read response

###################################################################
###################### Install Dependencies #######################
###################################################################

if [ "$response" = no ];then
	echo -e "\e[31m****** Quitting!!! ******\e[0m "
	cd
	rm -R /tmp/gns3/GNS3-1.2.3.source
	echo -e "\e[31mFolder removed\e[0m "
	exit 0
else
	#echo -en "\e[31mPress Enter Twice ( Y U DO DISS ?) : \e[0m "
	sleep 3
	echo -e "\e[31mInstalling Packages, please be patient!\e[0m "
	# Make sure to run apt-get update !
	sudo apt-get update
	sudo apt-get install python3 libpcap-dev uuid-dev libelf-dev cmake python3-setuptools python3-pyqt4 python3-ws4py python3-zmq python3-tornado
	# some sort of problem installing python3-netifaces package
	# needs to be installed separate
	sudo apt-get install python3-netifaces
	echo
	echo -e "\e[32m****** All done installing packages ******\e[0m "
	sleep 2
	echo
fi

###################################################################
######################## Installation Stage #######################
###################################################################

# Dynamips install
cd dynamips*
mkdir build ; cd build
cmake ..
make
echo -e "\e[31m****** Installing Dynamips ******\e[0m "
sleep 1
sudo make install
echo
echo -e "\e[32m****** Dynamips installed ******\e[0m "
sleep 2
echo

# Server install
cd ..
cd ../gns3-server*
echo -e "\e[31m****** Installing GNS Server ******\e[0m "
sleep 1
sudo python3 setup.py install
echo
echo -e "\e[32m****** GNS3 Server installed ******\e[0m "
sleep 2

# GUI install
cd ../gns3-gui*
echo
echo -e "\e[31m****** Installing GNS GUI ******\e[0m "
sleep 1
sudo python3 setup.py install
echo
echo -e "\e[32m****** GNS3 GUI installed ******\e[0m "
sleep 2
echo

# VPCS Install
cd ../vpcs*/src
echo -e "\e[31m****** Attempting to install VPCS ******\e[0m "
echo
sleep 1
if [ "$architecture" = "x86_64" ];then
	echo -e "\e[34m****** 64 Bit Install ******\e[0m "
	sleep 1
	echo $(sudo ./mk.sh 64)
else
	echo -e "\e[34m****** 32 Bit Install ******\e[0m "
	sleep 1
	echo $(sudo ./mk.sh 32 )
fi

# Copy the binary to /usr/bin
sudo cp vpcs /usr/bin
echo -e "\e[32m****** Virtual PC is installed ******\e[0m "
echo -e "\e[32m*** You can execute it from terminal by typing 'vpcs' and hitting enter ***\e[0m "
sleep 5
echo

# Create the application icon for GNS3
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
sudo cp $working_directory/gns3.png /usr/share/applications
echo -e $text > $working_directory/gns3.desktop && sudo mv $working_directory/gns3.desktop /usr/share/applications
# Give the file the proper permissions
sudo chmod u+x /usr/share/applications/gns3.desktop
sleep 2
echo -e "\e[32m****** All Done ******\e[0m "
echo
sleep 1

# Clean up
cd
echo -e "\e[31m****** House Cleaning! ******\e[0m " 
sudo rm -R /tmp/gns3
sleep 1
echo -e "\e[32m****** Folder removed ******\e[0m " 
echo

###################################################################
######## Check that all software installed successfully ###########
###################################################################

# First time bash function!
# Detects if the software has been installed correctly.
function sw_check {
	gns=$(which gns3)
	vpc=$(which vpcs)
	dmips=$(which dynamips)
	
	# As long as the variables return a value other than empty, the programs have installed
	if [ -n "$gns" ];then
		echo -e "\e[32m****** GNS3 Install Successful! ******\e[0m ";echo
		if [ -n "$vpc" ];then
			echo -e "\e[32m****** VPCS Install Successful! ******\e[0m ";echo
			if [ -n "$dmips" ];then
				echo -e "\e[32m****** Dynamips Install Successful! ******\e[0m ";echo
			else
				echo -e "\e[31mError, dynamips value = $dmips\e[0m "
			fi
		else
			echo -e "\e[31mError, vpcs value = $vpc\e[0m "
		fi
	else
		echo -e "\e[31mError, gns value = $gns\e[0m "
	fi
}

# Call the function to determine if the software was installed
sw_check

###################################################################
######################## Exiting script ###########################
###################################################################

echo -e "\e[31m****** Exiting from the script! ******\e[0m "
sleep 2
exit 0
