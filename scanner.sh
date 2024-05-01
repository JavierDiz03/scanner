#!/bin/bash

#colors
res='\e[0m'
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
white='\033[1;37m'

#current year and year -1
current_year=$(date +'%Y')
previous_year=$(date -d '1 year ago' +'%Y')

clear

files_permission() {

    echo " "
    files=$(sudo find / -type f -perm 777 2>/dev/null)
    echo -e "$blue[+]$res File with max-privilegies:\n"
    echo -e "$white$files$res"
    echo " "
}

running_services() {

    services=$(systemctl list-units --type=service --state=running --plain --no-legend | awk '{printf "%-40s %s\n", $1, $4}')
    echo " "
    echo -e "$blue[+]$res Actives services with vulnerabilities:\n"

    while read -r service state; do
        
	service_name=$(echo $service | awk '{print $1}')
        service_version=$(systemctl show -p Version $service_name | awk -F '=' '{print $2}')

        echo -e "$white$service_name:$res" 
        {
		vulnerabilities=$(curl -s "https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=$service_name+$service_version+$current_year" | grep -oE 'CVE-[0-9]{4}-[0-9]{4,}')
		echo -e "$red$vulnerabilities$res"
        } | sort | uniq | head -n 3
    done <<< "$services"
}

files_permission
running_services
