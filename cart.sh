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
Validate $? "Disabling Nodejs"

dnf module enable nodejs:18 -y &>> $Log_file
Validate $? "Enabling nodejs"

dnf install nodejs -y &>> $Log_file
Validate $? "Installing Nodejs"

id roboshop &>> $Log_file
if [ $? -ne 0 ]
then 
    useradd roboshop
else
    echo -e "$Y user already exit skipping $N"
fi

mkdir -p /app &>> $Log_file
Validate $? "Creating directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $Log_file
Validate $? "Downloading cart app" 

unzip -o /tmp/cart.zip &>> $Log_file
Validate $? "Unzipping cart"

npm install &>> $Log_file
Validate $? "Downloading dependencies"

cp /home/centos/roboshop_shell/cart.repo /etc/systemd/system/cart.service &>> $Log_file
Validate $? "copied cart conf"

systemctl daemon-reload &>> $Log_file
Validate $? "Reloading daemon"

systemctl enable cart &>> $Log_file
Validate $? "Enabling cart"

systemctl start cart &>> $Log_file
Validate $? "Staeting cart"