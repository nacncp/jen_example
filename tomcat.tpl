#!/bin/bash
sudo yum remove -y java-1.8.0-openjdk-headless.x86_64
sudo yum install -y java-17-openjdk.x86_64
sudo cd /usr/local/
sudo wget -P /usr/local/ https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.19/bin/apache-tomcat-10.1.19.tar.gz
sudo tar -xvf /usr/local/apache-tomcat-10.1.19.tar.gz -C /usr/local/
sudo mv /usr/local/apache-tomcat-10.1.19 /usr/local/tomcat
#sudo bash /usr/local/tomcat/bin/startup.sh
wget -P /usr/local/ https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j-8.2.0.tar.gz
tar -xvf /usr/local/mysql-connector-j-8.2.0.tar.gz -C /usr/local/
mv /usr/local/mysql-connector-j-8.2.0/mysql-connector-j-8.2.0.jar /usr/local/tomcat/lib


cat << EOF >> /usr/local/tomcat/webapps/ROOT/mysql.jsp
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=utf-8" %>
<%
         String DB_URL = "jdbc:mysql://${db_domain}:3306/mysql";
         String DB_USER = "msp001";
         String DB_PASSWORD= "user123!@#";
         Connection conn;
         Statement stmt;

         try {
              Class.forName("com.mysql.jdbc.Driver");
              conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
              stmt = conn.createStatement();
              conn.close();
              out.println("MySQL Connection Success!");
         }
         catch(Exception e){
              out.println(e);
         }
%>
EOF
#bash /usr/local/tomcat/bin/shutdown.sh
bash /usr/local/tomcat/bin/startup.sh

