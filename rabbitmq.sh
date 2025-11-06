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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $Log_file
Validate $? "installing rabbitmq erlang"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $Log_file
Validate $? "Installing rabbit mq server script"

dnf install rabbitmq-server -y &>> $Log_file
Validate $? "Installing server"

systemctl enable rabbitmq-server &>> $Log_file
Validate $? "Enabling server"

systemctl start rabbitmq-server &>> $Log_file
Validate $? "Starting server"

rabbitmqctl add_user roboshop roboshop123 &>> $Log_file
validate $? "Addign user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $Log_file
Validate $? "setting up permission"
