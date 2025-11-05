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
        echo -e "$R $2 falied $N"
    else
        echo -e "$G $2 successful $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R you need to be a root user to run this command $N"
    exit 1
else
    echo -e "$G you are a root user $N"
fi 

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $Log_file
Validate $? "coping mongodb repo"

dnf install mongodb-org -y &>> $Log_file
Validate $? "mongodb"

systemctl enable mongod &>> $Log_file
Validate $? "Enabling mongodb"


systemctl start mongod &>> $Log_file
Validate $? "Starting mongodb"


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $Log_file
Validate $? "Remote access to mongodb"


systemctl restart mongod &>> $Log_file
Validate $? "Restarting mongodb"