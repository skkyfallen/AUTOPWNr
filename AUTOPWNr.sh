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

REQUIRED_TOOLS=("nmap" "curl" "python3" "searchsploit" "grep" "awk" "msfconsole" "xmlstarlet")

check_dependencies() {
    echo "Checking dependencies........"
    # Check if required tools are installed
    for tool in "${REQUIRED_TOOLS[@]}"; do
        # Check if the tool is available in the system's PATH
        # If not, print an error message and set a flag
        if ! command -v "$tool" &> /dev/null; then
            echo -e "\e[1;31mError: $tool is not installed. Please install it before running this script.\e[0m"
            missing=1
        fi
    done
    # If all tools are installed, print success message
    if [ -z "$missing" ]; then
        echo -e "\e[1;32mAll required tools are installed.\e[0m"
    fi
}

nmap_scan() {
    echo -e "\e[1;34mStarting Nmap scan...\e[0m"
    read -p "Enter target IP or domain: " target
    read -a scan_type -p "Enter scan type (e.g., -sS for SYN scan, -sV for version detection): "
    echo "$scan_type"
   # Checks if target and scan type are empty
   if [ -z "$target" ] || [ ${#scan_type[@]} -eq 0 ]; then                  
     echo -e "\e[1;31mError: Target and scan type cannot be empty.\e[0m"
      return 1
    fi
    # Run nmap with the provided target and scan type
    nmap "${scan_type[@]}" "$target" -oX nmap_scan_$target.xml
    echo -e "\e[1;32mNmap scan completed. Results saved to nmap_scan_$target.xml.\e[0m"
}

xml_parse(){
    echo -e "\e[1;34mParsing Nmap XML results...\e[0m"
    # Checks if nmap_scan_$target.xml exists
    if [ ! -f "nmap_scan_$target.xml" ]; then
        echo -e "\e[1;31mError: Nmap scan results file not found.\e[0m"
        return 1
    fi
    # Use xmlstarlet to parse the XML and extract open ports, services, and versions
    xmlstarlet sel -t -m "//host/ports/port[state/@state='open']" \
    -v "concat('Port: ', @portid, ', Service: ', service/@name, ', Version: ', service/@product, ' ', service/@version)" -n \
    "nmap_scan_$target.xml" | sort > open_ports_$target.txt

    echo -e "\e[1;32mOpen ports saved to open_ports.txt.\e[0m"
}

searchsploit_services() {
    #searches through the nmap file
    echo -e "\e[1;34mSearching for exploits using SearchSploit...\e[0m"
    searchsploit --nmap nmap_scan_$target.xml > exploits_$target.txt
    echo -e "\e[1;32mExploits saved to exploits_$target.txt.\e[0m"
}

# Main script execution
check_dependencies

nmap_scan

xml_parse

searchsploit_services