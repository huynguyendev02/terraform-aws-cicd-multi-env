curl -fsSL https://get.docker.com -o get-docker.sh
sudo chmod +x get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
docker --version
