#!/bin/bash 
sudo yum remove -y java-1.8.0-openjdk-headless.x86_64 
sudo yum install -y java-17-openjdk.x86_64 
sudo cd /usr/local/ 
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.19/bin/apache-tomcat-10.1.19.tar.gz 
sudo tar -zxvf apache-tomcat-10.1.19.tar.gz 
sudo mv apache-tomcat-10.1.19 tomcat
sudo ./tomcat/bin/startup.sh
