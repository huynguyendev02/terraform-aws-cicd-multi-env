#!/bin/bash
sudo apt update -y
sudo apt install ruby-full -y
sudo apt install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sleep 10

echo -e "\n:enable_auth_policy: true" | sudo bash -c 'cat >> /etc/codedeploy-agent/conf/codedeployagent.yml'

cat /etc/codedeploy-agent/conf/codedeployagent.yml

sudo systemctl enable codedeploy-agent 
sudo systemctl status codedeploy-agent 

