#!/bin/bash

# Function to display a colorful and eloquent welcome message
welcome_message() {
    echo -e "\e[1;35m===============================\e[0m"
    echo -e "\e[0;34m  WELCOME TO THE ARCADE HAVEN  \e[0m"
    echo -e "\e[1;35m===============================\e[0m"
    echo -e "\e[0;33mStep into a world of fun and excitement, \e[0m"
    echo -e "\e[0;33mwhere adventure and challenges await you.\e[0m"
    echo -e "\e[1;32mPrepare yourself for an unforgettable experience!\e[0m"
    echo -e "\e[1;35m===============================\e[0m"
}

# Check if the player's name is passed as a command-line argument
if [ -z "$1" ]; then
    clear
    welcome_message
    read -p "Please enter your name: " player_name
else
    player_name="$1"
fi

# Arcade Menu
while true; do
    clear
    echo -e "\e[1;32m====================\e[0m"
    echo -e "\e[1;34m    Arcade Menu    \e[0m"
    echo -e "\e[1;32m====================\e[0m"
    echo "1. TIC-TAC-TOE"
    echo "2. TARGET"
    echo "3. BINGO ORB"
    echo "4. ROCK_PAPER_SCISSORS"
    echo "5. Exit"
    echo -e "\e[1;32m====================\e[0m"
    echo -e "\e[1;33mHello, $player_name! Get ready to choose your adventure.\e[0m"
    read -p "Choose a game to play (1-4): " choice

    case $choice in
        1) bash TICTACTOE.sh $player_name;;
        2) bash TARGET.sh $player_name ;;
        3) bash bingo.sh $player_name ;;
        4) bash rock_paper_scissors.sh $player_name ;;
        5) echo -e "\e[1;31mExiting...\e[0m"; exit 1 ;;
        *) echo -e "\e[1;31mInvalid option, please try again.\e[0m"
           sleep 1 ;;
    esac
done
