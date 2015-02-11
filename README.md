Bash Project Year 3 - GNS3 Installer script for Ubuntu 14.04 and derivatives (Work In Progress)

So this is my first attempt at a Bash scripting project and seeing as it is networking that I'm studying at the minute, I thought I could give back a little to new/future students on a similar trajectory to my own. GNS3 is without a doubt *THE* tool aspiring sys admins should be using to emulate/test/troubleshoot network topologies, at least IMO it is! I can't include any router images (something, something legal spegal) but I bet our mutual friend (Mr. Google) can help in that regard.

Included in the repo is the latest (as of most recent commit) source packages for GNS3, Dynamips and VPCS. This is pretty much only for testing purposes on my end as the script automatically retrieves this file upon execution.

To run the script, make sure you are in the directory in which it is contained : run "ls" from the terminal to list the contents of the current directory. Then make it execuable by typing : "chmod u+x ./gns3-installer.sh". Now you can run the script with "sudo ./gns3-installer.sh" (sudo will prompt for your password which the script needs to install dependencies and create certain fils/directories).
