#!/bin/bash
sudo dnf install -y httpd
sudo echo "good" >> /var/www/html/index.html
sudo cat << EOF >> /etc/httpd/conf/httpd.conf
LoadModule proxy_module modules/mod_proxy.so 
LoadModule proxy_http_module modules/mod_proxy_http.so 
<          jadujadujaduost *:80> 
        ServerName tomcat
	ProxyRequests Off 
	ProxyPreserveHost On 
	ProxyPass / http://${domain}:8080/  
	ProxyPassReverse / http://${domain}:8080/ 
</VirtualHost>
EOF
sed -i 's/          jadujadujadu/VirtualH/g'  /etc/httpd/conf/httpd.conf
sudo systemctl start httpd
