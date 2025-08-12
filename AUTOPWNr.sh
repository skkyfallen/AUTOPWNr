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
    scan_type=(-sV -T4)
    echo "${scan_type[@]}"
   # Checks if target and scan type are empty
   if [ -z "$target" ] || [ ${#scan_type[@]} -eq 0 ]; then                  
     echo -e "\e[1;31mError: Target and scan type cannot be empty.\e[0m"
      return 1
    fi
    results_dir="results/$target"
    if [ ! -d "$results_dir" ]; then
        mkdir -p "$results_dir"
        echo -e "\e[1;32mCreated directory: $results_dir\e[0m"
    fi
    # Run nmap with the provided target and scan type
    nmap "${scan_type[@]}" "$target" -oX "$results_dir/nmap_scan_$target.xml"
    echo -e "\e[1;32mNmap scan completed. Results saved to $results_dir/nmap_scan_$target.xml.\e[0m"

    echo -e "\e[1;34mParsing Nmap XML results...\e[0m"
    # Checks if nmap_scan_$target.xml exists
    if [ ! -f "$results_dir/nmap_scan_$target.xml" ]; then
        echo -e "\e[1;31mError: Nmap scan results file not found.\e[0m"
        return 1
    fi
    # Use xmlstarlet to parse the XML and extract open ports, services, and versions
    xmlstarlet sel -t -m "//host/ports/port[state/@state='open']" \
    -v "concat('Port: ', @portid, ', Service: ', service/@name, ', Version: ', service/@product, ' ', service/@version)" -n \
    "$results_dir/nmap_scan_$target.xml" | sort > "$results_dir/open_ports_$target.txt"

    echo -e "\e[1;32mOpen ports saved to open_ports_$target.txt.\e[0m"

    #searches through the nmap file
    echo -e "\e[1;34mSearching for exploits using SearchSploit...\e[0m"

    searchsploit --nmap "$results_dir/nmap_scan_$target.xml" > "$results_dir/exploits_$target.txt"
    echo -e "\e[1;32mExploits saved to exploits_$target.txt.\e[0m"
    #less "$results_dir/exploits_$target.txt"
    generate_report
}
generate_report() {
    echo -e "\e[1;34mGenerating report...\e[0m"
    report_file="$results_dir/report_$target.txt"
    {
        echo "Target: $target"
        echo "Scan Type: ${scan_type[*]}"
        echo "Open Ports and Services:"
        cat "$results_dir/open_ports_$target.txt"
        echo -e "\nExploits Found:"
        cat "$results_dir/exploits_$target.txt"
    } > "$report_file"
    echo -e "\e[1;32mReport generated: $report_file\e[0m"
}
#msfconsole_options() {
#    echo -e "\e[1;34mSetting up Metasploit options...\e[0m"
#    read -p "Enter local port (LPORT): " lport
#    read -p "Enter local IP (LHOST): " lhost
#    read -p "Enter exploit: " exploit
#    # Validate inputs
#    if [ -z "$exploit" ] || [ -z "$lport" ] || [ -z "$target" ]; then
#        echo -e "\e[1;31mError: Exploit, LPORT, and LHOST cannot be empty.\e[0m"``
#        return 1
#    fi
#}

#execute_msfconsole() {
#    echo -e "\e[1;34mLaunching Metasploit Framework...\e[0m"
#    msfconsole -q -x "use $exploit; set PAYLOAD $payload; set LPORT $lport; set RHOST $target; set LHOST $lhost; run"
#} 

#execute_msfvenom() {
#    echo -e "\e[1;34mCreating payload with msfvenom...\e[0m"
#    msfvenom -p "$payload" LHOST="$lhost" LPORT="$lport" -f elf > shell-x86.elf
#    echo -e "\e[1;32mPayload created: shell-x86.elf\e[0m"
#    execute_msfconsole
#}

#set_payload() {
#    echo -e "do you want to use msfvenom to create a payload? (y/n)"
#    read -r create_payload
#    if [[ "$create_payload" == "y" || "$create_payload" == "Y" ]]; then
#        read -p "Enter the msfvenom payload you want to use: " payload
#        execute_msfvenom
#    else
#        read -p "Enter the msfconsole payload you want to use: " payload
#        execute_msfconsole
#    fi
#}



# Main script execution
Main(){
    check_dependencies
    nmap_scan
}

Main

#msfconsole_options

#set_payload