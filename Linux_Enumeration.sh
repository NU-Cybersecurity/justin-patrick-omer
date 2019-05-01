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
# -Patrick- "Basic sysinfo summary. Plan on adding a check of the current version against available kernel updates and alerting if there's a new kernel update available."
printf "System Summary"
printf "$(uname -s) \n"
printf "$(uname -o) \n"
printf "$(uname -n) \n"
printf "$(uname -r) \n"
printf "$(uname -v) \n"
printf "$(uname -m) \n"

# User Information

# Services

# Find Interesting Files