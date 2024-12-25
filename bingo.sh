#!/bin/bash

# Function to display a colorful and eloquent welcome message for Bingo
welcome_message() {
    echo -e "\e[1;35m=============================================\e[0m"
    echo -e "\e[0;34m           WELCOME TO THE BINGO WORLD        \e[0m"
    echo -e "\e[1;35m=============================================\e[0m"
    echo -e "\e[0;33mDear $player_name,\e[0m"
    echo -e "\e[0;33mStep into the Bingo World, where every move \e[0m"
    echo -e "\e[0;33mbrings you closer to victory.\e[0m"
    echo -e "\e[1;32mGet ready for an unforgettable adventure!\e[0m"
    echo -e "\e[1;35m=============================================\e[0m"
}

how_to_play() {
    clear
    echo -e "\e[1;34m===============================\e[0m"
    echo -e "\e[1;33m         HOW TO PLAY          \e[0m"
    echo -e "\e[1;34m===============================\e[0m"
    echo -e "\e[0;32m1. Use the following keys to move the player:\e[0m"
    echo -e "\e[0;32m   - w: Move up\e[0m"
    echo -e "\e[0;32m   - s: Move down\e[0m"
    echo -e "\e[0;32m   - a: Move left\e[0m"
    echo -e "\e[0;32m   - d: Move right\e[0m"
    echo -e "\e[0;32m2. Press 'm' to mark a cell.\e[0m"
    echo -e "\e[0;32m3. The goal is to find and mark the random number shown.\e[0m"
    echo -e "\e[0;32m4. Once marked, the cell will display 'X'.\e[0m"
    echo -e "\e[0;32m5. Try to get Bingo by marking a full row, column, or diagonal.\e[0m"
    echo -e "\e[0;32m6. Your current position is marked in \e[1;31mred\e[0;32m on the board.\e[0m"
    echo -e "\e[0;32m7. The first column contains numbers 0 to 4, the second column contains\e[0m"
    echo -e "\e[0;32m   numbers 5 to 9, then 10-14, 15-19, and 20-24 respectively.\e[0m"
    echo -e "\e[0;32m8. You have 3 minutes to achieve as many Bingos as possible.\e[0m"
    echo -e "\e[1;34m===============================\e[0m"
    echo -e "\e[1;35m SAMPLE BINGO GRID:\e[0m"
    echo -e "\e[0;33m  0   5   10   15   20\e[0m"
    echo -e "\e[0;33m  1   6   11   16   21\e[0m"
    echo -e "\e[0;33m  2   7   12   17   22\e[0m"
    echo -e "\e[0;33m  3   8   13   18   23\e[0m"
    echo -e "\e[1;31m  4\e[0m\e[0;33m   9   14   19   24\e[0m"
    echo
    read -p "Press any key to return to the main menu..." -n 1 -s
}


# Function for countdown before the game starts
countdown() {
    echo -e "\e[1;31mThe game starts in...\e[0m"
    for i in {3..1}; do
        echo -e "\e[1;31m$i...\e[0m"
        sleep 1
    done
    echo -e "\e[1;32mGO!\e[0m"
}

play() {
    # Constants for the game
    GRID_SIZE=5
    PLAYER_CHAR="X"
    EMPTY_CHAR="O"
    CURRENT_CHAR="*"
    RANGE_DIF=$GRID_SIZE
    SLEEP_TIME=5
    GAME_TIME=180  # Total game time in seconds (3 minutes)
    RAND_FILE="rand_value.txt"
    START_TIME=$(date +%s)
    BINGO=0

    # Initialize the player's position
    player_x=0
    player_y=1

    # Create the Bingo board
    declare -A board
    board[0,0]="B"
    board[1,0]="I"
    board[2,0]="N"
    board[3,0]="G"
    board[4,0]="O"
    for ((y = 1; y < GRID_SIZE + 1; y++)); do
        min=0
        max=$((GRID_SIZE-1))
        for ((x = 0; x < GRID_SIZE; x++)); do
            board[$x,$y]=$(( RANDOM % (max - min + 1) + min ))
            min=$((min + RANGE_DIF))
            max=$((max + RANGE_DIF))
        done
    done

    # Initialize RAND with a random value and write it to the file
    RAND=$(( RANDOM % (GRID_SIZE*GRID_SIZE) ))
    echo $RAND > $RAND_FILE

    # Function to draw the Bingo board
    draw_board() {
        clear
        echo "Commands:"
        echo "Press w to move upwards"
        echo "Press s to move downwards"
        echo "Press d to move right"
        echo "Press a to move left"
        echo "Press m to mark the cell"
        echo "Press o to quit"
        echo " "
        
        # Calculate remaining time
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        REMAINING_TIME=$((GAME_TIME - ELAPSED_TIME))

        # Format the remaining time as MM:SS
        REMAINING_MINUTES=$((REMAINING_TIME / 60))
        REMAINING_SECONDS=$((REMAINING_TIME % 60))
        printf "Time remaining: %02d:%02d\n" $REMAINING_MINUTES $REMAINING_SECONDS
        echo "BINGO: $BINGO"

        RAND=$(cat $RAND_FILE)
        echo "Find $RAND"
        echo " " 

        echo "----BINGO BOARD----"

        # Loop through the grid and print it with color for the player's position
        for ((y = 0; y < GRID_SIZE + 1; y++)); do
            for ((x = 0; x < GRID_SIZE; x++)); do
                if [[ $x -eq $player_x && $y -eq $player_y ]]; then
                    printf "\e[1;31m%3s\e[0m " "${board[$x,$y]}"
                else
                    printf "%3s " "${board[$x,$y]}"
                fi
            done
            echo
        done
    }

    # Function to update the player's position
    update_player() {
        case $player_direction in
            "UP") ((player_y--)) ;;
            "DOWN") ((player_y++)) ;;
            "LEFT") ((player_x--)) ;;
            "RIGHT") ((player_x++)) ;;
            "NONE") ;;
        esac

        # Keep player within the board
        if ((player_x < 0)); then player_x=0; fi
        if ((player_x >= GRID_SIZE)); then player_x=$((GRID_SIZE - 1)); fi
        if ((player_y < 1)); then player_y=1; fi
        if ((player_y >= GRID_SIZE + 1)); then player_y=$((GRID_SIZE)); fi
    }

    # Mark the cell
    mark() {
        if [[ ${board[$player_x,$player_y]} -eq $RAND ]]; then
            board[$player_x,$player_y]="X"
        else
            return 0
        fi

        # Check column
        flag=0
        for ((y = 1; y < GRID_SIZE + 1; y++)); do
            if [[ ${board[$player_x,$y]} -ne "X" ]]; then
                flag=1
                break
            fi
        done
        if [[ $flag -eq 0 ]]; then
            ((BINGO++))
        fi

        # Check row
        flag=0
        for ((x = 0; x < GRID_SIZE; x++)); do
            if [[ ${board[$x,$player_y]} -ne "X" ]]; then
                flag=1
                break
            fi
        done
        if [[ $flag -eq 0 ]]; then
            ((BINGO++))
        fi

        # Check major diagonal
        if [[ $player_x -eq $player_y-1 ]]; then
            flag=0
            for ((i = 0; i < GRID_SIZE; i++)); do
                if [[ ${board[$i,$((i+1))]} -ne "X" ]]; then
                    flag=1
                    break
                fi
            done
            if [[ $flag -eq 0 ]]; then
                ((BINGO++))
            fi
        fi

        # Check minor diagonal
        if [[ $((player_x + player_y)) -eq $GRID_SIZE ]]; then
            flag=0
            for ((i = 0; i < GRID_SIZE; i++)); do
                if [[ ${board[$i,$((GRID_SIZE-i))]} -ne "X" ]]; then
                    flag=1
                    break
                fi
            done
            if [[ $flag -eq 0 ]]; then
                ((BINGO++))
            fi
        fi
    }

    FLAG=0 #to check if o has been pressed
    # Function to handle user input for direction
    read_input() {
        read -n 1 -s -t 1 input
        case $input in
            w) player_direction="UP" ;;
            s) player_direction="DOWN" ;;
            a) player_direction="LEFT" ;;
            d) player_direction="RIGHT" ;;
            m) mark ;;
            o) FLAG=1
               ;;
        esac
    }

    # Function to update RAND value every 5 seconds and write to the file
    update_rand() {
        while true; do
            sleep $SLEEP_TIME
            RAND=$(( RANDOM % (GRID_SIZE*GRID_SIZE) ))
            echo $RAND > $RAND_FILE
        done
    }

    # Start updating RAND in the background
    update_rand &
    rand_pid=$!

    # Set trap to kill the background process when exiting
    trap "kill $rand_pid" EXIT

    # Main game loop
    while true; do
        # Check if game time has elapsed
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if ((ELAPSED_TIME >= GAME_TIME || FLAG == 1)); then
            break
        fi

        player_direction="NONE"
        draw_board
        read_input
        update_player
    done

    # Clean up the background process explicitly if loop exits naturally
    kill $rand_pid
    wait $rand_pid 2>/dev/null
}

# Function to display end-of-game message
end_game_message() {
    clear
    echo -e "\e[1;35m===========================================\e[0m"
    echo -e "\e[1;31m           Time's up! Game End.            \e[0m"
    echo -e "\e[1;35m===========================================\e[0m"
    if [[ $BINGO -eq 0 ]]; then
        echo -e "\e[1;31mYou did not get any Bingo :( \e[0m"
        echo -e "\e[1;33mAll the best next time! \e[0m"
    elif [[ $BINGO -eq 1 ]]; then
        echo -e "\e[1;32mHurray! You got a Bingo!! :D \e[0m"
    else
        echo -e "\e[1;33mLEGENDARY!!! You got \e[1;32m$BINGO \e[1;33mBingos :O :O \e[0m"
    fi
    echo -e "\e[1;35m===========================================\e[0m"
    read -p "Press any key to return to the main menu..." -n 1 -s
}


# Check if the player's name is passed as a command-line argument
if [ -z "$1" ]; then
    echo -e "\e[1;31mError: Please provide your name as an argument.\e[0m"
    exit 1
else
    player_name="$1"
    clear
    welcome_message
    sleep 2
    while true; do
        clear
        echo " "
        echo -e "\e[1;33mWhat would you like to do?\e[0m"
        echo "1. Start playing Bingo"
        echo "2. See how to play"
        echo "3. Go back to Arcade menu"
        read -p "Choose an option (1-3): " response

        case "$response" in
            1)
            countdown
            play
            end_game_message
            ;;
        2)
            how_to_play
            ;;
        3)
            # Instead of exiting, break the loop to return to the source script
            break
            ;;
        *)
            echo -e "\e[1;31mInvalid option. Please choose a valid option.\e[0m"
            ;;
        esac
    done
fi
    
