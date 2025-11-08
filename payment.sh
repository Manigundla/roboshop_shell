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

dnf install python36 gcc python3-devel -y &>> $Log_file
Validate $? "Installing python"

id roboshop &>> $Log_file #in this scripts we can use 'set -e', but in case of this cmd.its doesn't work because the user is not created before running this script for the first time then its is a error and scritp will exit.
    if [ $? -ne 0 ] #the if statement helps to validate the username 
    then
        useradd roboshop &>> $Log_file
        Validate $? "added user"
    else 
        echo -e "user already exit $Y skipping $N"
    fi

mkdir -p /app &>> $Log_file
Validate $? "Creating directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $Log_file
Validate $? "Downloading code"

cd /app &>> $Log_file

unzip -o /tmp/payment.zip &>> $Log_file
Validate $? "Unzipping code"

pip3.6 install -r requirements.txt &>> $Log_file
Validate $? "Installing dependencies"

cp /home/centos/roboshop_shell/payment.repo /etc/systemd/system/payment.service &>> $Log_file
Validate $? "copied conf"

systemctl daemon-reload &>> $Log_file
Validate $? "Relaoding daemon"

systemctl enable payment &>> $Log_file
Validate $? "Enabling Payment"

systemctl start payment &>> $Log_file
Validate $? "Starting payment"