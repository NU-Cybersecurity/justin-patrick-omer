#! /bin/bash
# This script is intended to help users in an offensive and defensive manner when trying to enumerate a local linux machine for permissions issues.
# This could include misconfigured file permissions, user permissions, sudo privileges, etc. 
# After finding an issue, the script will attempt to provide advice for remediation (Dynamic or Static?)
# Okay, so first we need to layout the sections of what we're trying to enumerate. Feel free to add more. I figure the current four is a decent amount? I know there are plenty of other
# Linux Enumeration scripts out there with more but I want to see what we can create on our own and with what we know should be checked.
# Cool ASCII text because... Why not?

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec >	>(tee -i /tmp/Linux_Enumerator_Report-"$(date --date=today +%m-%d-%y-%T).log")
# Without this, only stdout would be captured - i.e. log file would not contain any error messages.
# log file would not contain any error messages.
exec 2>&1


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


printf "\n \nA COPY OF THE RESULTS WILL BE CREATED AT: /tmp/Linux_Enumerator_Report-"$(date --date=today +%m-%d-%y-%T).log"  "

# System Information
#"Basic sysinfo summary."


printf "\n \n"
printf "		SYSTEM SUMMARY \n"
printf "Hostname:			$(uname -n) \n"
printf "Operating System:		$(uname -o) \n"
printf "Distribution:			$(sed -n '/DISTRIB_ID/p' /etc/*-release | awk -F "=" '{print $2}') \n"
printf "Kernal Name: 			$(uname -s) \n"
printf "Kernel Release:			$(uname -r) \n"
printf "Kernel Version: 		$(uname -v) \n"
printf "System Architecture:		$(uname -m) \n"
printf "\n \n"

#Network Information
printf "		NETWORK INTERFACE SUMMARY \n"
printf "$( ip addr show | sed -n '/valid/!p' | awk -F " " '{print $2}')"
printf "\n"

#DNS Information
printf "		DNS SERVER SUMMARY \n"
printf "$(sed -n '/nameserver/p' /etc/resolv.conf  | awk -F" " '{print $2}')"
printf "\n"

# User Information
#Print username in /etc/passwd, excluding those with the /sbin/nologin or /bin/false
printf "		USERS WITH BASH PRIVILEGES \n" 
 printf "$(cat /etc/passwd | sed -n '/false/!p' | sed -n '/nologin/!p' | awk -F":" '{print $1}')"
 printf "\n"
 # Print all other users (i.e. service accounts)
 printf "		USERS WITHOUT BASH PRIVILEGES \n	'i.e. Service Accounts or Disabled Accounts' \n"
 printf "$(cat /etc/passwd | sed -n '/bash/!p' | awk -F":" '{print $1}')"
 printf "\n"
 

#Check who has sudo access
USER="printf "$(cat /etc/passwd | awk -F":" '{print $1}')""
GROUP="printf "$(cat /etc/group | awk -F":" '{print $1}')""
printf "\n"
printf "        	USERS WITH SUDO PRIVILEGES \n \n"
for i in $USER
do
USERSUDO="$(grep -e "$i"  /etc/sudoers | sed -n '/#/!p' | sed -n '/User_Alias/!p' | sed -n '/root/!p' | sed -n '/bin/!p')"
if [[ $USERSUDO != "" ]]
then
printf "$i \n"
fi
done
printf "\n"
printf "        	GROUPS WITH SUDO PRIVILEGES \n \n"
for i in $GROUP
do
GROUPSUDO="$(grep -e "$i" /etc/sudoers | sed -n '/#/!p' | sed -n '/bin/!p' | sed -n '/User_Alias/!p' | sed -n '/root/!p')"
if [[ $GROUPSUDO != "" ]]
then
printf "$i \n"
printf "Users in "$i" group:"
printf "$(cat /etc/group | sed -n "/$i/p" | awk -F ":" '{$1=$2=$3="";print $0}')"
printf "\n \n"
fi
done
printf "\n \n"
for i in $USER
do


# Checking if any entries include NOPASSWD
NOPASSWD="$(sed -n '/NOPASSWD/p' /etc/sudoers | sed -n '/#/!p' | sed -n '/root/!p' | sed -n "/$i/p" | awk '{print $1}')"
if [ "$NOPASSWD" != "" ]
then
printf "		WARNING \nUser $i SUDOERS configuration contains NOPASSWD \n"
else
continue
fi
done
for i in $GROUP
do
NOPASSWD="$(sed -n '/NOPASSWD/p' /etc/sudoers | sed -n '/#/!p' | sed -n '/root/!p' | sed -n "/$i/p" | awk '{print $1}')"
if [ "$NOPASSWD" != "" ]
then
printf "		WARNING \nGroup $i SUDOERS configuration contains NOPASSWD \n"
else
continue
fi
done


# Services
#Checking if Distro is Redhat/Centos or other, using Systemctl for Redhat/Centos and Services for other. 
DISTRO="$(sed -n '/DISTRIB_ID/p' /etc/*-release | awk -F "=" '{print $2}')"
if [ "$DISTRO" == "Red Hat" ] && [ "$DISTRO" == "Centos" ]
then
printf "		Distribution = Red Hat or Centos \n		checking Systemctl. \n"
printf "$(systemctl | sed -n '/service/p' | sed -n '/active/p' | awk -F"." '{print $1}')"
else 
printf "		Distribution = Ubuntu, Debian or Other \n			checking Service. \n		 	'?' = Status Unknown \n		 	'+' = Status Running \n "
printf "$(service --status-all | sed -n '/+/p')"
fi


# Find Interesting Files

