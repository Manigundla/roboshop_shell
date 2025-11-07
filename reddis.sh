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
        echo -e "$R $2 is failed $N"
        exit 1
    else 
        echo -e "$G $2 is successful $N"
    fi
}


if [ $ID -ne 0 ]
then 
     echo -e "$R you should run this script as a root user $N"
     exit 1
else 
    echo -e "$G you are a root user $N"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.9.rpm -y &>> $Log_file
Validate $? "Installing remirepo"

dnf module enable redis:remi-6.2 -y &>> $Log_file
Validate $? "Installing remirepo"

dnf install redis -y &>> $Log_file
Validate $? "Installing remirepo"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $Log_file
Validate $? "editing remote acces"

systemctl enable redis &>> $Log_file
Validate $? "enabling reddis"

systemctl start redis &>> $Log_file
Validate $? "starting redis"