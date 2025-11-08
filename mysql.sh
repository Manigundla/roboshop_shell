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

dnf install mysql-server -y &>> $Log_file
Validate $? "Instaliing Msql"

systemctl enable mysqld &>> $Log_file
Validate $? "Enabling mysql"

systemctl start mysqld &>> $Log_file
Validate $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $Log_file
Validate $? "Installing and setting password"