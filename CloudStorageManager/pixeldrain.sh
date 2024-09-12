#!/usr/bin/env bash

source ./functions.sh 
source ./config.sh

error_message=""
success_message=""

if [ -z "${PixelDrain_API_Key}" ]; then
	error_message="Please set your PixelDrain Api Key in ./config.sh"
	print_error
	pkill -f 'main.sh|pixeldrain.sh' > /dev/null 2>&1
	exit 1
fi

page_num=0
items_per_page=5

function handle_upload() {
	read -r -p "Path of file to upload: " upload_filename
		error_message=$(verify_file "${upload_filename}")
		if [ -z "${error_message}" ]; then 
			curl -T "${upload_filename}" -u :"${PixelDrain_API_Key}" https://pixeldrain.com/api/file/
		fi
}

function handle_download() {
	read -r -p "Select the number of the file you want to download: " item
	((item--))

	if [[ $item -lt 0 ]] || [[ $item -ge $num_files ]]; then
		error_message="Invalid selection."
	else
		item_json=$(echo "$files" | jq -r --argjson index "$item" '.files[$index]')
		if [[ -z "$item_json" ]]; then
			error_message="Failed to retrieve item."
		else
			item_id=$(echo "$item_json" | jq -r '.id')
			item_name=$(echo "$item_json" | jq -r '.name')

            response=$(curl -s -w "%{http_code}" -o "$item_name" -u :"${PixelDrain_API_Key}" "https://pixeldrain.com/api/file/${item_id}")
            
            http_code=$(echo "$response" | tail -n1)
            
            if [[ "$http_code" -eq 200 ]]; then
                if [[ -s "$item_name" ]]; then
                    success_message="Successfully downloaded $item_name"
                else
                    error_message="Downloaded file is empty. There might be an issue with the download."
					rm "$item_name"
                fi
            else
                if [[ "$http_code" -eq 403 ]]; then
                    error_message="Access forbidden. Possible hotlinking restriction."
					rm "$item_name"
                else
                    error_message="Failed to download file. HTTP status code: $http_code"
					rm "$item_name"
                fi
            fi

		fi
	fi
}

function handle_info() {
	read -r -p "Select the number of the file you want info on: " item
	((item--))

	if [[ $item -lt 0 ]] || [[ $item -ge $num_files ]]; then
		error_message="Invalid selection."
	else
		item_json=$(echo "$files" | jq -r --argjson index "$item" '.files[$index]')
		if [[ -z "$item_json" ]]; then
			error_message="Failed to retrieve item."
		else
			pixel_parse_json "$item_json"
			read -n 1 -s -r -p "Press any key to continue..."
		fi
	fi
}

function handle_delete() {
	read -r -p "Select the number of the file you want to delete: " item
			((item--))

			if [[ $item -lt 0 ]] || [[ $item -ge $num_files ]]; then
				error_message="Invalid selection."
			else
				item_json=$(echo "$files" | jq -r --argjson index "$item" '.files[$index]')
				if [[ -z "$item_json" ]]; then
					error_message="Failed to retrieve item."
				else
					item_id=$(echo "$item_json" | jq -r '.id')
					item_name=$(echo "$item_json" | jq -r '.name')
					
					while true; do
						printf "${RED}Are you sure you want to delete ${item_name}? (y/n): ${RESET}"
						read -r deletion_choice
						deletion_choice=$(echo "$deletion_choice" | tr '[:upper:]' '[:lower:]')

						case $deletion_choice in
							"y" | "yes")
								curl -s -X DELETE -u :"${PixelDrain_API_Key}" "https://pixeldrain.com/api/file/${item_id}" > /dev/null 2>&1
								success_message="Successfully deleted $item_name"
								break
								;;
							"n" | "no")
								error_message="Deletion aborted"
								break
								;;
							*)
								tput cuu1
								tput el
								tput cuu1
								tput el
								echo "Please respond with either yes or no"
								;;
						esac
					done
				fi
			fi
}

while true; do
	files=$(fetch_files)
	num_files=$(echo "$files" | jq -r '.files[] | .name' | wc -l)
	max_pages=$(((num_files + items_per_page - 1) / items_per_page - 1))
	
	clear
	show_files

	printf "${CYAN}${UNDERLINE}What would you like to do?:${RESET}\n"
	printf "${BLUE}1)${RESET} upload\n"
	printf "${BLUE}2)${RESET} download\n"
	printf "${BLUE}3)${RESET} info\n"
	printf "${BLUE}4)${RESET} delete\n"
	printf "${BLUE}5)${RESET} previous page\n"
	printf "${BLUE}6)${RESET} next page\n"
	printf "${BLUE}7)${RESET} return to main menu\n"

	print_error
	print_success
	echo

	read -r -p "Choice: " action

	action=$(echo "$action" | tr '[:upper:]' '[:lower:]')

	case $action in 
		"1" | "upload")
			handle_upload
			;;
		"2" | "download")
			handle_download
			;;
		"3" | "info") 
			handle_info
			;;
		"4" | "delete") 
			handle_delete
			;;
		"5" | "back" | "previous" | "previous page") 
			if ((page_num > 0)); then
				((page_num--))
			else
				error_message="Currently on first page"
			fi
			;;
		"6" | "next" | "next page") 
			if ((page_num < max_pages)); then
				((page_num++))
			else
				error_message="Currently on last page"
			fi
			;;
		"7" | "return to main menu" | "return" | "main menu") 
			exit 0
			;;
		"quit") 
			printf "\nGoodbye\n"
			pkill -f 'main.sh|pixeldrain.sh' > /dev/null 2>&1
			exit 0
			;;
		*) 
			error_message="Not an option. Try again"
		;;
	esac
done