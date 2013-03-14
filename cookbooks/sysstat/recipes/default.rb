#
# Cookbook Name:: sysstat
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "sysstat" do
  action :install
end

case node['platform_family']
when 'debian'
  template "sysstat" do
    path "/etc/default/sysstat"
    source "sysstat"
    owner "root"
    group "root"
    mode 0644
  end
when 'rhel'
  raise 'not implemented'
end

service "sysstat" do |e|
  service_name "sysstat"
  
  action :enable
  action :start
end

