#!/bin/bash

set -e

echo "=== Installing development tools for Ubuntu/Debian ==="

# Ensure the script is not run as root
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Please use a regular user with sudo access."
  exit 1
fi

# --- Docker ---
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker is already installed."
fi

# --- Docker Compose ---
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt update
    sudo apt install -y docker-compose
else
    echo "Docker Compose is already installed."
fi

# --- Python 3.9+ ---
PYTHON_VERSION_REQ="3.9"
if command -v python3 &> /dev/null; then
  PYTHON_VERSION_INS=$(python3 -c 'import sys; print(sys.version_info[0], sys.version_info[1], sep=".")')
  if python3 -c "import sys; exit(0 if sys.version_info >= (${PYTHON_VERSION_REQ//./, }) else 1)" 2>/dev/null; then
    echo "Python $PYTHON_VERSION_INS is already installed."
  else
    echo "Python $PYTHON_VERSION_INS is installed but version $PYTHON_VERSION_REQ or higher is required. Installing..."
    sudo apt install -y python3
  fi
else
  echo "Installing Python..."
  sudo apt install -y python3
  echo "Python has been successfully installed"
fi

# --- pip ---
if command -v pip3 &> /dev/null; then
  echo "pip is already installed."
else
  echo "Installing pip..."
  sudo apt install -y python3-pip
  echo "pip has been successfully installed"
fi

# --- Django ---
if python3 -c "import django" &> /dev/null; then
  echo "Django is already installed."
else
  echo "Installing Django..."
  sudo apt install -y python3-django
  echo "Django has been successfully installed via apt"
fi

# --- Summary ---
echo "=== Installation complete! Tool versions: ==="
docker --version || echo "Docker not found"
docker-compose --version || echo "Docker Compose not found"
python3 --version
echo -n "Django "
python3 -m django --version || echo "Django not found"