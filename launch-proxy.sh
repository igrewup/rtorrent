#!/bin/bash
# Bash Menu Script Example

echo " Setting up ENCRYPTED tunnel to Proxy Server"
echo " To close your session, close the window or hit CTRL+C"

PS3='Please enter your choice: '
options=("SERVER1" "SERVER2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "SERVER1")
		echo ""
		echo $opt
		exec ssh proxy1
            ;;
        "SERVER2")
                echo ""
		echo $opt
                exec ssh proxy2
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option ;;
    esac
done

pause 'Press [Enter] key to exit...'
