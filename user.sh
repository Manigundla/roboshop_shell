#!/bin/bash 

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Timestamp=$(date +%F-%H-%M-%S)
Log_file="/tmp/$0-$Timestamp.log"


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

dnf module disable nodejs -y &>> $Log_file
Validate $? "Disabling nodejs"

dnf module enable nodejs:18 -y &>> $Log_file
Validate $? "Enabling nodejs"

dnf install nodejs -y &>> $Log_file
Validate $? "Installing nodejs"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop
    Validate $? "roboshop user created"
else
    echo -e "$Y user already exit skipping $N"
fi
 
mkdir -p /app &>> $Log_file
Validate $? "creating directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $Log_file #-L The -L (or --location) option tells curl to automatically follow these redirects until it reaches the final destination
Validate $? "Downloading user application"

cd /app 
unzip -o /tmp/user.zip &>> $Log_file
Validate $? "Unzipping code"

npm install &>> $Log_file
Validate $? "Downloading dependencies"

cp /home/centos/roboshop_shell/user.repo /etc/systemd/system/user.service &>> $Log_file
Validate $? "Copied user conf"

systemctl daemon-reload &>> $Log_file
Validate $? "Reloading daemon"

systemctl enable user &>> $Log_file
Validate $? "Enabling user"

systemctl start user &>> $Log_file
Validate $? "Starting user"

cp  home/centos/roboshop_shell/mongodb.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y &>> $Log_file
Validate $? "Installing mongodb clinet"

mongo --host mongodb.chainverse.online </app/schema/user.js &>> $Log_file
Validate $? "Loading date to mongodb"
