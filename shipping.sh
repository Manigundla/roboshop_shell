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

dnf install maven -y
Validate $? " Installing maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
Validate $? "adding user"

mkdir -p /app 
Validate $? "Creating directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
Validate $? "Downloading code"

cd /app 


unzip -o /tmp/shipping.zip
Validate $? "Unzipping shipping"

mvn clean package
Validate $? "downloading dependencies"

mv target/shipping-1.0.jar shipping.jar 
Validate $? "Renaming jar file"

cp /home/centos/roboshop_shell/shipping.repo /etc/systemd/system/shipping.service
Validate $? "coping shipping conf"

systemctl daemon-reload
Validate $? "Reloading daemon"

systemctl enable shipping 
Validate $? "Enabling shipping"

systemctl start shipping
Validate $? "Starting shiiping"

dnf install mysql -y 
Validate $? "Installing mysql"

mysql -h mysql.chainverse.online -uroot -pRoboShop@1 < /app/db/schema.sql
Validate $? "pushing schema into mysql"

mysql -h mysql.chainverse.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
Validate $? "pushing user info into msql"

mysql -h mysql.chainverse.online -uroot -pRoboShop@1 < /app/db/master-data.sql
Validate $? "pushing master-data"

systemctl restart shipping 
Validate $? "restarting shipping"