# Application Security Group
resource "aws_security_group" "application_sg" {
  name        = "application-security-group"
  description = "Security group for web applications"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_app_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.application_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.CSYE6225-profile.name

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
LOG_FILE="/home/csye6225/user-data-log.txt"

echo "Running user data script..." > $LOG_FILE
cd /home/csye6225/my_app/
echo "Creating .env file..." >> $LOG_FILE
touch .env

echo DB_HOST="${aws_db_instance.postgres_rds.address}" >> .env
echo DB_PORT="5432" >> .env
echo DB_USERNAME="${aws_db_instance.postgres_rds.username}" >> .env
echo DB_PASSWORD="${var.db_password}" >> .env
echo DB_NAME="${aws_db_instance.postgres_rds.db_name}" >> .env
echo AWS_Bucket_Name="${aws_s3_bucket.csye6225_bucket.bucket}" >> .env
echo AWS_Region="${var.aws_region}" >> .env
echo PORT="8080" >> .env

# Restart application service
echo "Setting permissions and starting application service..." >> $LOG_FILE
sudo systemctl enable my_app_service.service >> $LOG_FILE 2>&1
sudo systemctl start my_app_service.service >> $LOG_FILE 2>&1

# Configure CloudWatch Agent
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null << 'EOT'
{
  "agent": {
    "metrics_collection_interval": 10,
    "logfile": "/var/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/csye6225/my_app/logs/webapp.log",
            "log_group_name": "${aws_cloudwatch_log_group.csye6225.name}",
            "log_stream_name": "${aws_cloudwatch_log_stream.webappLogStream.name}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${var.metrics_namespace}",
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metrics_collection_interval": 10
      }
    }
  }
}
EOT

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl restart amazon-cloudwatch-agent

# Check the status of the CloudWatch Agent  
sudo systemctl status amazon-cloudwatch-agent >> $LOG_FILE 2>&1

echo "User data script completed." >> $LOG_FILE
EOF

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "Web-App-Instance"
  }
}
