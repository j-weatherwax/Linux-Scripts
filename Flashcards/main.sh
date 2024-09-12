#!/usr/bin/env bash

cd Decks

# Check if there are any files in the directory
if [[ -z $(ls -A) ]]; then
    echo "No files found in the Decks directory."
    exit 1
fi

echo "Which deck would you like to study?"

select file in *; do
    if [[ -n "$file" && -f "$file" ]]; then
        deck="$file"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

card_count=$(wc -l < "$deck")

question_bank=($(seq "$card_count"))

while [ ${#question_bank[@]} -gt 0 ]; do
    index=$((RANDOM % ${#question_bank[@]}))
    chosen_card=${question_bank[index]}
    card=$(sed -n "${chosen_card}p" "$deck")
    IFS='/' read -r question answer <<< "$card"

    clear
    echo "Q: $question"
    echo

    read -n 1 -s -r -p "Press any key to show answer..."

    printf "\033[0G\033[K"  
    echo "A: $answer"

    while true; do
        echo "Press 1 to remove card from deck or Press 2 to shuffle and try again"
        read -r choice
        case $choice in
            1)
                question_bank=("${question_bank[@]:0:$index}" "${question_bank[@]:$((index + 1))}")
                break
                ;;
            2)
                break
                ;;
            *)
                echo "Invalid choice. Please press 1 to remove the card or 2 to try again."
                ;;
        esac
    done
done

echo "Deck completed!"