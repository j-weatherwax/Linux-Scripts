#!/usr/bin/env bash

source ./config.sh

#ANSI CODES
RED="\e[0;31m"
ITALICRED="\e[3;31m"
GREEN="\e[0;32m"
CYAN="\e[1;36m"
BLUE="\e[0;36m"
UNDERLINE="\e[4m"
RESET="\e[0m"

function print_usage() {
    echo "$(basename "$0"): usage: [pixel / mega / google] (-f [filename] | -d [directory])"
}

function print_error {
	if [ -n "$error_message" ]; then
		printf "\n${ITALICRED}${error_message}${RESET}\n"
		error_message=""
	fi
}

function print_success {
	if [ -n "$success_message" ]; then
		printf "\n${GREEN}${success_message}${RESET}\n"
		success_message=""
	fi
}

get_api_key() {
    local key_name="$1"
    local key_value="${!key_name}"

    if [ -z "$key_value" ]; then
        echo "Error: $key_name is empty"
        exit 1
    else
        echo "$key_value"
    fi
}

function verify_file() {
	local filename="$1"
    if [ -z "${filename}" ]; then
        echo "Error: Filename not provided"
        print_usage 
    fi
    
    if [ ! -f "${filename}" ]; then
        echo "Error: File '${filename}' not found or is not a regular file"
    fi
}

pixel_parse_json() {
    local json="$1"

    local fields=(
        "name"
        "id"
        "size"
        "views"
        "mime_type"
        "thumbnail_href"
        "can_download"
        "downloads"
        "date_upload"
        "date_last_view"
        "delete_after_date"
        "delete_after_downloads"
        "download_speed_limit"
        "hash_sha256"
    )

    echo
    for field in "${fields[@]}"; do
        value=$(echo "$json" | jq -r --arg field "$field" '.[$field]')
        echo "${field^}: $value"
    done
    echo
}

fetch_files() {
    curl -s -u :"${PixelDrain_API_Key}" https://pixeldrain.com/api/user/files
}

show_files() {
    local start=$((page_num * items_per_page))
    local end=$(((page_num + 1) * items_per_page))
    local file_names=$(echo "$files" | jq -r '.files[] | .name')
    local num_files=$(echo "$file_names" | wc -l)
    if ((end > num_files)); then
        end=$num_files
    fi
    local count=0
    local file_list=()

    printf "${CYAN}${UNDERLINE}FILE LIST:${RESET}\n"
    while IFS= read -r file; do
        if [ "$count" -ge "$start" ] && [ "$count" -lt "$end" ]; then
            file_list+=("$file")
            printf "${BLUE}$((count + 1)))${RESET} $file\n"
        fi
        ((count++))
    done <<< "$file_names"

    echo
}