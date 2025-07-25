#! /bin/bash
clear
echo -e "\e[1;31m"
echo " _______          _________ _______  _______           _        _______ "
echo "(  ___  )|\     /|\__   __/(  ___  )(  ____ )|\     /|( (    /|(  ____ )"
echo "| (   ) || )   ( |   ) (   | (   ) || (    )|| )   ( ||  \  ( || (    )|"
echo "| (___) || |   | |   | |   | |   | || (____)|| | _ | ||   \ | || (____)|"
echo "|  ___  || |   | |   | |   | |   | ||  _____)| |( )| || (\ \) ||     __)"
echo "| (   ) || |   | |   | |   | |   | || (      | || || || | \   || (\ (   "
echo "| )   ( || (___) |   | |   | (___) || )      | () () || )  \  || ) \ \__"
echo "|/     \|(_______)   )_(   (_______)|/       (_______)|/    )_)|/   \__/"
echo -e "\e[0m"
echo ""
echo -e "\e[1;37m        [ AutoPWNr – Automated Recon & Exploitation Tool ]\e[0m"
echo -e "\e[0;33m                      ⚠️  FOR LAB USE ONLY ⚠️ \e[0m"
echo ""
sleep 1

REQUIRED_TOOLS=("nmap" "curl" "python3" "searchsploit" "grep" "awk" "metasploit-framework" "msfconsole")

check_dependencies() {
    echo "Checking dependencies........"
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "\e[1;31mError: $tool is not installed. Please install it before running this script.\e[0m"
        fi
    done
}

check_dependencies
