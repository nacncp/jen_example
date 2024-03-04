<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=utf-8" %>
          <%
	  String DB_URL = "jdbc:mysql://${db_domain}:3306/${db_name}";
	  String DB_USER = "${db_user}";
	  String DB_PASSWORD= "${db_passwd}";
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
