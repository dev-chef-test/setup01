#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, NAME
#
# All rights reserved - Do Not Redistribute
#

# install pack
%w{traceroute wget sysstat tcpdump ntpdate ntp iotop vim mlocate tree }.each do |setup| #
  package setup do
    action :install
  end
end

execute "yum.update" do #
  command "yum -y update"
  action :run
end

# Centos Timezone JST 
link "/etc/localtime" do #
  to "/usr/share/zoneinfo/Asia/Tokyo"
end

# chkconfig ntpd ntpdate
%w{ntpdate ntpd}.each do |ntpservice| #
  service ntpservice do
    action [:enable]
  end
end

# start ntpdate
###service "ntpdate" do #
###  action [:restart]
###end

# mod /etc/ntp.conf
# restart ntpd
template "ntp.conf" do #
  path "/etc/ntp.conf"
  source "ntp.conf.erb"
  mode 0644
  notifies :restart, 'service[ntpd]' 
end
