Bash Project Year 3 - GNS3 Installer script for Ubuntu 14.04 and derivatives (Work In Progress)

So this is my first attempt at a Bash scripting project and seeing as it is networking that I'm studying at the minute, I thought I could give back a little to new/future students on a similar trajectory to my own. GNS3 is without a doubt *THE* tool aspiring sys admins should be using to emulate/test/troubleshoot network topologies, at least IMO it is! I can't include any router images (something, something legal spegal) but I bet our mutual friend (Mr. Google) can help in that regard.

Included in the repository is the latest (as of most recent commit) source packages for GNS3, Dynamips and VPCS. This is pretty much only for testing purposes on my end as the script automatically retrieves this file upon execution.

[Running The Script]
First off, open the terminal and create a new directory (name of your choosing) with "mkdir new_directory".
Next, cd into the newly created directory with "cd new_directory".
This next step requires that git is installed, run "which git" which should output the path to the binary. 
If the output is empty that means you need to install git, run "sudo apt-get install git".
Once git is installed type "sudo git clone https://github.com/k1nk33/GNS3-Installer".
Again, using the cd command, change directory to the newly created GNS3-Installer directory & make the script execuable by typing "sudo chmod u+x ./gns3-installer.sh". 
Now you can run the script with "sudo ./gns3-installer.sh" (sudo may prompt for your password which the script needs to install dependencies and create certain files/directories).
 
[Once Installed]
Unfortunately I can't (legally anyway) provide the Cisco IOS images required to emulate Cisco routers. My recommendations are not to go crazy downloading every IOS image you come across as
that can quicly get out of hand. Instead focus on ones that provides the most features that you require. I have found that the 3725 & 3745 images suit most of my needs. I'm sure Google can help. 
Happy hunting and I hope this made it a little easier on you. :)  
