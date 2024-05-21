#!/bin/sh
echo "Installing SSM"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo yum install -y ec2-instance-connect
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent