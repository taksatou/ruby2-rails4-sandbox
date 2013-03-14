#
# Cookbook Name:: rbenv
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node['platform_family']
when 'debian'
  execute "apt-get-update-periodic" do
    command "apt-get update"
    ignore_failure true
    only_if do
      File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
        File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
    end
  end
  
  %w{git make libreadline-dev libssl-dev}
when 'rhel'
  %w{git gcc make readline-devel openssl-devel}
end . each { |pkg| package(pkg) { action :install } }

git node['user']['home'] + "/.rbenv" do
  not_if 'file ' + node['user']['home'] + "/.rbenv"
  
  user node['user']['name']
  group node['user']['group']
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  # action :sync
  action :checkout
end

bash "rbenv_plugin" do
  user node['user']['name']
  group node['user']['group']
  code "mkdir -p " + node['user']['home'] + "/.rbenv/plugins"
end

git node['user']['home'] + "/.rbenv/plugins/ruby-build" do
  not_if 'file ' + node['user']['home'] + "/.rbenv/plugins/ruby-build"
  
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  # action :sync
  action :checkout
end

bash "rbenv_install" do
  not_if { File.exists?(node['user']['home'] + "/.rbenv/shims/ruby") }

  user node['user']['name']
  group node['user']['group'] 
  cwd node['user']['home']
  environment "HOME" => node['user']['home']
#  path ['$HOME/.rbenv/bin']

  code <<-EOC
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bash_profile
    echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
    source $HOME/.bash_profile
    rbenv install #{node['rbenv']['version']}
    rbenv global #{node['rbenv']['version']}
    rbenv versions
    rbenv rehash
  EOC
end
