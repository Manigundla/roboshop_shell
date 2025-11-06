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

dnf install python36 gcc python3-devel -y
Validate $? "Installing python"

id roboshop &>> $Log_file #in this scripts we can use 'set -e', but in case of this cmd.its doesn't work because the user is not created before running this script for the first time then its is a error and scritp will exit.
    if [ $? -ne 0 ] #the if statement helps to validate the username 
    then
        useradd roboshop &>> $Log_file
        Validate $? "added user"
    else 
        echo -e "user already exit $Y skipping $N"
    fi

mkdir -p /app 
Validate $? "Creating directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip
Validate $? "Downloading code"

cd /app 

unzip -o /tmp/payment.zip
Validate $? "Unzipping code"

pip3.6 install -r requirements.txt
Validate $? "Installing dependencies"

cp /home/centos/roboshop_shell/payment.repo /etc/systemd/system/payment.service
Validate $? "copied conf"

systemctl daemon-reload
Validate $? "Relaoding daemon"

systemctl enable payment 
Validate $? "Enabling Payment"

systemctl start payment
Validate $? "Starting payment"