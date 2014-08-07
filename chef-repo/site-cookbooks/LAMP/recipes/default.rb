#
# Cookbook Name:: LAMP
# Recipe:: default
#
# Copyright 2014, NAME
#
# All rights reserved - Do Not Redistribute
#

bash 'add_epel' do
  user 'root'
  code <<-EOC
    rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/epel.repo
  EOC
  creates "/etc/yum.repos.d/epel.repo"
end

###bash 'add_rpmforge' do
###  user 'root'
###  code <<-EOC
###    rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
###    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/rpmforge.repo
###  EOC
###  creates "/etc/yum.repos.d/rpmforge.repo"
###end

###bash 'add_remi' do
###  user 'root'
###  code <<-EOC
###    rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
###    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/remi.repo
###  EOC
###  creates "/etc/yum.repos.d/remi.repo"
###end

# install lamp

%w{php mysql-server php-mysql php-mcrypt httpd }.each do |lamp| #
  package lamp do
    action :install
  end
end

# install phpMyAdmin
package "phpMyAdmin" do
  action :install
end

# chkconfig httpd on
service "httpd" do #
  action [:restart, :enable]
end

# mysqld start
# chkconfig mysqld on
service "mysqld" do #
  action [:restart, :enable]
end

script "Secure_Install" do
  interpreter 'bash'
  user "root"
  only_if "mysql -u root -e 'show databases'"
  code <<-EOL
    mysqladmin -u root password "your_password"
    mysql -u root -pyour_password -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -pyour_password -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');"
    mysql -u root -pyour_password -e "DROP DATABASE test;"
    mysql -u root -pyour_password -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -pyour_password -e "FLUSH PRIVILEGES;"
  EOL
end

# php.ini
##template "php.ini" do #
##  path "/etc/php.ini"
##  source "php.ini.erb"
##  mode 0644
##end

##template "index.html" do #
##  path "/var/www/html/index.html"
##  source "index.html.erb"
##  mode 0644
##end

# httpd.conf
##template "httpd.conf" do 
##  path "/etc/httpd/conf/httpd.conf"
##  source "httpd.conf.erb"
##  mode 0644
##  notifies :restart, 'service[httpd]' 
##end

# my.cnf
##template "my.cnf" do 
##  path "/etc/my.cnf"
##  source "my.cnf.erb"
##  mode 0644
##  notifies :restart, 'service[mysqld]' 
##end

# mod /etc/httpd/conf.d/phpMyAdmin.conf
# restart httpd
template "phpMyAdmin.conf" do #
  path "/etc/httpd/conf.d/phpMyAdmin.conf"
  source "phpMyAdmin.conf.erb"
  mode 0644
  notifies :restart, 'service[httpd]' 
end
