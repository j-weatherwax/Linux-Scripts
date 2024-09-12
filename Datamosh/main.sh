#!/usr/bin/env bash

file="$1"
soxflag=false
overlay=false

usage() {
    echo "Usage: $0 <filename> [-s] [-v] [-o <value>]"
    echo "-s    Use sox instead of default algorithm to edit data"
    echo "-v     Overlays output on top of original image"
    echo "-o <value>    Set output location of image"
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

mime_type=$(file --mime-type -b "$file")

image_mime_types=("image/jpeg" "image/png" "image/gif" "image/bmp" "image/webp" "image/tiff")

if [[ ! " ${image_mime_types[@]} " =~ " ${mime_type} " ]]; then
    echo "Input file must be an image"
    exit 1
fi

ext="${file##*.}"
base="${file%.*}"

OUTPUT_FILE="${base}_output.${ext}"

shift

while getopts ":sov:" opt; do
    case $opt in
        s) soxflag=true;;
        o) 
            OUTPUT_FILE="$OPTARG"
            if [[ "$OUTPUT_FILE" != *.* ]]; then
                OUTPUT_FILE="${OUTPUT_FILE}.${ext}"
            fi
            ;;
        v) overlay=true;;
        \?) usage ;;  # Invalid option
    esac
done

if $soxflag; then
    echo "Loading $(basename "$file") into sox..."

    convert "$file" img.bmp

    sox -q -t ul -c 1 -r 48k img.bmp -t ul img2.bmp trim 0 100s : phaser 0.3 0.9 1 0.7 0.5 -t highpass 300 echos 0.8 0.7 20 0.25 63 0.3 

    # Convert the final output file
    if $overlay; then
        composite -gravity center img2.bmp "$file" "$OUTPUT_FILE"
    else
        convert img2.bmp "$OUTPUT_FILE"
    fi

    rm img.bmp img2.bmp

else
    echo "Loading $(basename "$file") into default algorithm..."

    # Extract the first 128 bytes and store them as a hexadecimal string
    header=$(dd if="$file" bs=1 count=128 2>/dev/null | xxd -p | tr -d '\n')

    data=$(dd if="$file" bs=1 skip=128 2>/dev/null | xxd -p | tr -d '\n')
    tempdata=$(mktemp)
    data_processed=$(mktemp)
    echo "$data" > "$tempdata"

    ./data_ops "$tempdata" > $data_processed

    cat <(echo "$header") "${data_processed}" | xxd -r -p > "$OUTPUT_FILE"

    rm "$tempdata" "$data_processed"

    if $overlay; then
        composite -gravity center "$OUTPUT_FILE" "$file" "$OUTPUT_FILE"
    fi

fi

echo "Modified file saved as '$OUTPUT_FILE'"
