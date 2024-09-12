#!/usr/bin/env bash

file="$1"

usage() {
    echo "Usage: $0 <filename>"
    exit 1
}

if [ $# -lt 1 ]; then
	usage
    exit 1
fi

if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found!"
    usage
    exit 1
fi

is_image() {
    file --mime-type "$1" | grep -q 'image/'
}

is_video() {
    file --mime-type "$1" | grep -q 'video/'
}

is_gif() {
    file --mime-type "$1" | grep -q 'image/gif'
}

precompute_frames() {
    local output_dir=$1
    local ext=$2
    local frame_count=0
    local total_frames=$(ls "$temp_dir"/*."$ext" | wc -l)

    echo "Total frames to process: $total_frames"

    for img in "$temp_dir"/*."$ext"; do
        output_file=$(printf "%s/frame_%04d.txt" "$temp_dir" "$frame_count")
        ./precompute "$img" > "$output_file"

        progress=$((frame_count * 100 / total_frames))
        printf "\rProcessing frames: [%d%%] %d/%d" "$progress" "$frame_count" "$total_frames"

        ((frame_count++))
    done
    echo
}

display_frames() {
    local frame_delay=0.1
    local frame_dir=$1

    for frame_file in "$frame_dir"/*.txt; do
        local frame_data=$(cat "$frame_file")
        echo -ne "\033[H"  # Move cursor to the top-left corner
        echo -e "$frame_data"
        sleep "$frame_delay"
    done
}

ext=bmp

if is_image "$file" && ! is_gif "$file"; then

    temp_dir=$(mktemp -d)
    resize="${temp_dir}/resized_image.${ext}"
    convert "$file" -resize 30x "$resize"

    precompute_frames $temp_dir $ext

    clear
    display_frames $temp_dir

    rm -rf "$temp_dir"

elif is_video "$file" || is_gif "$file";  then
    temp_dir=$(mktemp -d)
    echo "Generating frames..."
    ffmpeg -i "$file" -vf "scale=-1:30" -r 10 "$temp_dir"/frame_%04d."$ext" -loglevel quiet
    
    echo "Parsing data..."
    precompute_frames $temp_dir $ext
    
    clear
    display_frames $temp_dir

    rm -rf "$temp_dir"
else
    echo "File must be an image or video"
    exit 1
fi