#!/usr/bin/env bash
source ./functions.sh
source ./config.sh

error_message=""

while true; do
	clear
	printf "${CYAN}${UNDERLINE}Enter the cloud service you would like to use:${RESET}\n"
	printf "${BLUE}1)${RESET} PixelDrain\n"
	printf "${BLUE}2)${RESET} Mega\n"
	printf "${BLUE}3)${RESET} Google Drive\n"
	printf "${BLUE}4)${RESET} quit\n"

	print_error
	echo

	read -r -p "Choice: " service

	service=$(echo "$service" | tr '[:upper:]' '[:lower:]')

	case $service in
		"1" | "pixeldrain" | "pixel")
			./pixeldrain.sh
			;;
			
		"2" | "mega")
			./mega.sh
			;;
		"3" | "google drive" | "google" | "drive")
			./google.sh
			;;
		
		"4" | "quit") 
			printf "\nGoodbye\n"
			exit 0
			;;
		
		*)
			error_message="Not a valid service. Try again."
			;;
	esac
done