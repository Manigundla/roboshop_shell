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
Validate $? "Disabling Nodejs"

dnf module enable nodejs:18 -y
Validate $? "Enabling nodejs"

dnf install nodejs -y
Validate $? "Installing Nodejs"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop
else
    echo -e "$Y user already exit skipping $N"
fi

mkdir -p /app
Validate $? "Creating directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
Validate $? "Downloading cart app" 

unzip -o /tmp/cart.zip
Validate $? "Unzipping cart"

npm install 
Validate $? "Downloading dependencies"

cp /home/centos/roboshop_shell/cart.repo /etc/systemd/system/cart.service
Validate $? "copied cart conf"

systemctl daemon-reload
Validate $? "Reloading daemon"

systemctl enable cart 
Validate $? "Enabling cart"

systemctl start cart
Validate $? "Staeting cart"