#!/bin/bash 

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Timestamp=$(date +%F-%H-%M-%S)
Log_file="/tmp/$0-$Timestamp.log"
exec >> $Log_file 2>&1

Validate(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$R $2 failed $N"
        exit 1
    else 
        echo -e "$G $2 succesfull $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R you need to run this command as a root user $N"
    exit 1
else 
    echo -e "$G you are a root user $N"
fi

dnf module disable nodejs -y
Validate $? "Disabling nodejs"

dnf module enable nodejs:18 -y
Validate $? "Enabling nodejs"

dnf install nodejs -y
validate $? "Installing nodejs"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop
else
    echo -e "$Y user already exit skipping $N"
fi
 
mkdir -p /app
Validate $? "creating directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip #-L The -L (or --location) option tells curl to automatically follow these redirects until it reaches the final destination
Validate $? "Downloading user application"

cd /app 
unzip -o /tmp/user.zip
Validate $? "Unzipping code"

npm install
Validate $? "Downloading dependencies"

cp /home/centos/roboshop_shell/user.repo /etc/systemd/system/user.service
Validate $? "Copied user conf"

systemctl daemon-reload
Validate $? "Reloading daemon"

systemctl enable user 
Validate $? "Enabling user"

systemctl start user
Validate $? "Starting user"

cp  home/centos/roboshop_shell/mongodb.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-org-shell -y 
Validate $? "Installing mongodb clinet"

mongo --host mongodb.chainverse.online </app/schema/user.js
Validate $? "Loading date to mongodb"
