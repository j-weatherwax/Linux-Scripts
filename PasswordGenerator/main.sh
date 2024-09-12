#!/usr/bin/env bash

function is_digit(){
  local var=$1
  if [[ $var =~ ^[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

while true; do
  read -p "Password length: " length

  if ! is_digit "$length"; then
    echo "Must enter a number for length"
  elif [ "$length" -lt 8 ]; then
    echo "Choose a number greater than 7. The longer a password is, the more secure it will be."
  else
    break
  fi
done

lowercase_array=($(echo {a..z}))
uppercase_array=($(echo {A..Z}))
digit_array=($(echo {0..9}))
special_array=( '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '-' '_' '=' '+' '[' ']' '{' '}' '|' ';' ':' ',' '.' '/' '?' '<' '>' '?' )

full_char_array=("${lowercase_array[@]}" "${uppercase_array[@]}" "${digit_array[@]}" "${special_array[@]}")

password=()

lowercase_len=${#lowercase_array[@]}
uppercase_len=${#uppercase_array[@]}
digit_len=${#digit_array[@]}
special_len=${#special_array[@]}
full_char_len=${#full_char_array[@]}

#Ensures at least one lowercase, uppercase, digit, and special character are present in the password
password[0]=${lowercase_array[$((RANDOM % lowercase_len))]}
password[1]=${uppercase_array[$((RANDOM % uppercase_len))]}
password[2]=${digit_array[$((RANDOM % digit_len))]}
password[3]=${special_array[$((RANDOM % special_len))]}

for ((i=4; i<length; i++)); do
  password[$i]=${full_char_array[$((RANDOM % full_char_len))]}
done

#Password is shuffled to prevent required characters from being fixed at the start
password=$(printf "%s\n" "${password[@]}" | shuf | tr -d '\n')

echo "Generated password: ${shuffled_password[@]}"