#!/bin/bash

Id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Timestamp=$(date +%F-%H-%M-%S)
Log_file="/tmp/$0-$Timestamp.Log"


Validate(){
    if [ $1 -ne 0 ]
    then    
        echo -e "$R $2 failed $N"
    else
        echo -e "$G $2 successful $N"
    fi
}


if [ $Id -ne 0 ]
then 
    echo -e "$R you shoould be root user to run this command $N"
else 
    echo -e "$G you are a root user $N"
fi

dnf install nginx -y &>> $Log_file
Validate $? "installing nginx"

systemctl enable nginx &>> $Log_file
Validate $? "enabining nginx"
 

systemctl start nginx &>> $Log_file
Validate $? "starting nginx"


rm -rf /usr/share/nginx/html/* &>> $Log_file
Validate $? "deleting default code"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $Log_file
Validate $? "downloading code"

cd /usr/share/nginx/html &>> $Log_file
Validate $? "changing directory"

unzip /tmp/web.zip &>> $Log_file
Validate $? "unzipping code"

cp /home/centos/roboshop_shell/web.repo /etc/nginx/default.d/roboshop.conf &>> $Log_file
Validate $? "copied conf"

systemctl restart nginx &>> $Log_file
Validate $? "restarting nginx"