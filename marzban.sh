
#!/bin/bash

# Default values
GITHUB_REPOSITORY="du79sw/Marzban"
GITHUB_BRANCH="master"
MYSQL_SUPPORT=false
MARIADB_SUPPORT=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --database)
            if [ "$2" = "mysql" ]; then
                MYSQL_SUPPORT=true
            elif [ "$2" = "mariadb" ]; then
                MARIADB_SUPPORT=true
            fi
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Install required packages
apt update
apt install -y curl git python3 python3-pip

# Clone Marzban repository
git clone https://github.com/$GITHUB_REPOSITORY.git /opt/marzban
cd /opt/marzban

# Install Python requirements
if [ "$MYSQL_SUPPORT" = true ]; then
    apt install -y python3-dev default-libmysqlclient-dev build-essential pkg-config
    pip install -r requirements.txt mysqlclient
elif [ "$MARIADB_SUPPORT" = true ]; then
    apt install -y python3-dev libmariadb-dev build-essential pkg-config
    pip install -r requirements.txt mariadb
else
    pip install -r requirements.txt
fi

# Create environment file
cp .env.example .env

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Create service
bash install_service.sh

# Start service
systemctl enable marzban
systemctl start marzban

# Perform database migration
echo "Performing database migration..."
alembic upgrade head

echo "Installation completed!"
echo "The web interface is available on http://localhost:8000/dashboard"
echo "Default credentials:"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "IMPORTANT: После внесения изменений нужно будет выполнить миграцию базы данных для добавления нового поля."
echo "To perform migration after changes, run: cd /opt/marzban && alembic upgrade head"
