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
else 
    echo -e "$G you are a root user $N"
fi

dnf module disable nodejs -y &>> $Log_file
Validate $? "disabling nodejs"

dnf module enable nodejs:18 -y &>> $Log_file
Validate $? "enabling nodejs"

dnf install nodejs -y &>> $Log_file
Validate $? "installing nodejs" 

useradd roboshop &>> $Log_file
Validate $? "added user"

mkdir /app &>> $Log_file
Validate $? "created app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $Log_file
Validate $? "downloading applicatino"

cd /app &>> $Log_file

unzip /tmp/catalogue.zip &>> $Log_file
Validate $? "unzipping catalouge"

cd /app

npm install &>> $Log_file
Validate $? "downloading dependices"  

cp /home/centos/roboshop_shell/catalogue.repo /etc/systemd/system/catalogue.service &>> $Log_file


systemctl daemon-reload &>> $Log_file
Validate $? "reloading daemon"

systemctl enable catalogue &>> $Log_file
Validate $? "Enabling catalouge"

systemctl start catalogue &>> $Log_file
Validate $? "starting catalouge"

cp /home/centos/roboshop_shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $Log_file
Validate $? "coping mongodb client repo"

dnf install mongodb-org-shell -y &>> $Log_file 
Validate $? "Installing Mongodb client"

mongo --host mongodb.chainverse.online </app/schema/catalogue.js &>> $Log_file
Validate $? "Loading data in mangodb server"