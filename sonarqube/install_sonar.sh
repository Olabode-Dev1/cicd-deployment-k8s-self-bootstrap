#!/bin/bash

# Backup sysctl.conf before modification
sudo cp /etc/sysctl.conf /root/sysctl.conf_backup

# Modify Kernel System Limits for SonarQube
echo "Modifying kernel system limits for SonarQube..."
sudo sh -c 'cat <<EOF > /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOF'
sudo sysctl -p  # Apply the changes

# Update system and install OpenJDK 11
echo "Updating system and installing OpenJDK 11..."
sudo apt update -y
sudo apt install openjdk-11-jdk -y

# Install PostgreSQL
echo "Installing PostgreSQL..."
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update -y
sudo apt install postgresql postgresql-contrib -y

# Enable and start PostgreSQL service
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

# Configure PostgreSQL
echo "Configuring PostgreSQL..."
sudo echo "postgres:admin123" | sudo chpasswd
sudo runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"

# Restart PostgreSQL service to apply changes
sudo systemctl restart postgresql

# Install SonarQube
echo "Installing SonarQube..."
sudo mkdir /sonarqube/
cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip
sudo apt-get install zip -y
sudo unzip -o sonarqube-8.3.0.34182.zip -d /opt/
sudo mv /opt/sonarqube-8.3.0.34182/ /opt/sonarqube

# Create a user for SonarQube
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar

# Backup sonar.properties before modification
sudo cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup

# Modify SonarQube configuration
echo "Configuring SonarQube..."
sudo chown sonar:sonar /opt/sonarqube/ -R
sudo sh -c 'cat <<EOF > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOF'

# Create systemd service for SonarQube
echo "Setting up SonarQube as a systemd service..."
sudo sh -c 'cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd, enable and start the SonarQube service
echo "Enabling and starting SonarQube service..."
sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service
sudo systemctl start sonarqube.service

# Start SonarQube manually to ensure it's running
sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start

# Reboot system
echo "Rebooting the system..."
sudo reboot
