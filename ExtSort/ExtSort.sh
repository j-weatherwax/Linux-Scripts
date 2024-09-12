#!/usr/bin/env bash
set -euo pipefail

function get_ext() {
	local ext_list=()
	
	# Save current value of IFS
    local oldIFS="$IFS"
    
    # Set IFS to only split on newlines
    IFS=$'\n'

	for file in ${files[@]}; do 
		
		# Skip processing files without extensions
		if [[ "${file}" != *.* ]]; then
			ext_list+=("empty_ext")
			continue
		fi
		
		#remove upper directories from the path and keep only the text after the period
		#example: /user/file.txt -> file.txt -> txt
		ext=$(basename "$file" | cut -d'.' -f2)
		ext_list+=("$ext")
	done
	
	# Reset IFS to its original value
    IFS="$oldIFS"
	
	#Iterate through ext_list | convert all ext to lowercase | remove duplicates
	echo $(printf "%s\n" "${ext_list[@]}" | tr '[:upper:]' '[:lower:]' | sort -u)
}

# Main
read -p "Enter the directory path to organize files: " directory

#Find all files in the directory | 
files=$(find "$directory" -type f)

extensions=$(get_ext "${files[@]}")

#Create directories if they don't exist
for ext in ${extensions[@]}; do
	if [ ! -d "$directory/${ext}" ]; then
		mkdir -p "$directory/${ext}"
	fi
done

#sort files into their respective directories
# Set IFS to only split on newlines
IFS=$'\n'
for file in ${files[@]}; do
	
	if [[ "${file}" != *.* ]]; then
		ext="empty_ext"
	else 
		ext=$(basename "$file" | cut -d'.' -f2)
	fi
	
	mv "${file}" "$directory/${ext}"
done


echo "Files sorted"