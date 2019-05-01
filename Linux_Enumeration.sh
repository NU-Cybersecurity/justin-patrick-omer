#! /bin/bash

# This script is intended to help users in an offensive and defensive manner when trying to enumerate a local linux machine for permissions issues.
# This could include misconfigured file permissions, user permissions, sudo privileges, etc. 
# After finding an issue, the script will attempt to provide advice for remediation (Dynamic or Static?)

# Okay, so first we need to layout the sections of what we're trying to enumerate. Feel free to add more. I figure the current four is a decent amount? I know there are plenty of other
# Linux Enumeration scripts out there with more but I want to see what we can create on our own and with what we know should be checked.

# Cool ASCII text because... Why not?
ascii()
{
    cat << "EOF"
         __    _                     ______                                      __            
        / /   (_)___  __  ___  __   / ____/___  __  ______ ___  ___  _________ _/ /_____  _____
       / /   / / __ \/ / / / |/_/  / __/ / __ \/ / / / __ `__ \/ _ \/ ___/ __ `/ __/ __ \/ ___/
      / /___/ / / / / /_/ />  <   / /___/ / / / /_/ / / / / / /  __/ /  / /_/ / /_/ /_/ / /    
     /_____/_/_/ /_/\__,_/_/|_|  /_____/_/ /_/\__,_/_/ /_/ /_/\___/_/   \__,_/\__/\____/_/     
EOF
}

# Define help options of -h and -?
help()
{
    echo "There are currently no other options other than -h and -? (help) for now. Usage of this script only requires you to run it."
}

while getopts ":h?" opt; do
    case ${opt} in
        h ) help; exit;;
        ? ) help; exit;;
    esac
done

ascii

# System Information
# -Patrick- "Basic sysinfo summary."


printf "\n \n"
printf "	SYSTEM SUMMARY \n"
printf "Hostname: 		$(uname -n) \n"
printf "Operating System: 	$(uname -o) \n"
printf "Kernal Name: 		$(uname -s) \n"
printf "Kernel Release: 	$(uname -r) \n"
printf "Kernel Version: 	$(uname -v) \n"
printf "System Architecture: 	$(uname -m) \n"
printf "\n \n"


# User Information
#Print username in /etc/passwd, excluding those with the /sbin/nologin or /bin/false
printf "	USER ACCOUNTS WITH BASH ACCESS \n" 
 printf "$(cat /etc/passwd | sed -n '/false/!p' | sed -n '/nologin/!p' | awk -F":" '{print $1}')"
 printf "\n"
 # Print all other users (i.e. service accounts)
 printf "	USER ACCOUNTS WITHOUT BASH ACCESS 'i.e. Service Accounts' \n"
 printf "$(cat /etc/passwd | sed -n '/bash/!p' | awk -F":" '{print $1}')"
 printf "\n"
 #Check who has sudo access
USER="printf "$(cat /etc/passwd | awk -F":" '{print $1}')""
GROUP="printf "$(cat /etc/group | awk -F":" '{print $1}')""
printf "\n"
printf "        CHECKING SUDOERS FILE \n"
printf "        USER ACCOUNTS WITH SUDO CAPABILITIES \n \n"
for i in $USER
do
grep -e "$i"  /etc/sudoers | sed -n '/#/!p' | sed -n '/User_Alias/!p' | sed -n '/root/!p' | sed -n '/bin/!p'
done
printf "\n"
printf "        GROUP ACCOUNTS WITH SUDO CAPABILITIES \n \n"
for i in $GROUP
do
grep -e "$i" /etc/sudoers | sed -n '/#/!p' | sed -n '/bin/!p' | sed -n '/User_Alias/!p' | sed -n '/root/!p'
done
printf "\n \n"
printf "        CHECKING IF ANY USERS HAVE NOPASSWD | WARNING | IF ANY RESULTS ARE PRODUCED, THESE USERS DO NOT REQUIRE TO AUTHENTICATE TO ESCALATE PRIVILEGES | THIS IS NOT RECOMMENDED  \n \n"
printf "$(sed -n '/NOPASSWD/p' /etc/sudoers | sed -n '/#/!p' | sed -n '/root/!p')"
printf "\n \n"
 
 
 printf "	CHECKING WHEEL GROUP: \n"
 printf "$(cat /etc/group | sed -n '/wheel/p' | awk -F ":" '{$1=$2=$3="";print $0}')"
 
# Services

# Find Interesting Files
