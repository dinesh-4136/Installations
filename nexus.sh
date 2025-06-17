#!/bin/bash

set -e  # Exit on any error

# Step 1: Update packages and install Java
echo "Updating packages and installing OpenJDK..."
sudo apt update -y
sudo apt install openjdk-11-jdk wget -y

# Step 2: Download and extract Nexus
echo "Downloading and extracting Nexus..."
cd /tmp
wget https://download.sonatype.com/nexus/3/nexus-3.80.0-06-linux-x86_64.tar.gz
tar -xvf nexus-3.80.0-06-linux-x86_64.tar.gz
mv nexus-3.80.0-06 nexus3

# Step 3: Move Nexus files to /opt
echo "Moving Nexus files to /opt..."
sudo mv nexus3 /opt
sudo mv sonatype-work /opt

# Step 4: Create nexus user and set ownership
echo "Creating 'nexus' user and setting ownership..."
sudo useradd -r -s /bin/false nexus
sudo chown -R nexus:nexus /opt/nexus3
sudo chown -R nexus:nexus /opt/sonatype-work

# Step 5: Create systemd service file
echo "Creating systemd service for Nexus..."
sudo bash -c 'cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/bin/bash /opt/nexus3/bin/nexus start
ExecStop=/bin/bash /opt/nexus3/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF'

# Step 6: Reload systemd and start Nexus
echo "Starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Step 7: Show Nexus status
echo "Checking Nexus service status..."
sudo systemctl status nexus
