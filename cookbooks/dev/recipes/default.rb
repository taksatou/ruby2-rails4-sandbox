#
# Cookbook Name:: dev
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
  
  %w{git make autotools-dev dstat lv zsh emacs vim ngrep }
when 'rhel'
  []                            # TODO
end . each { |pkg| package(pkg) { action :install } }

bash "misc" do
  user node['user']['name']
  group node['user']['group']
  code "mkdir -p " + node['user']['home'] + "/misc"
end

git node['user']['home'] + "/misc/dotfiles" do
  not_if 'file ' + node['user']['home'] + "/misc/dotfiles"
  
  user node['user']['name']
  group node['user']['group']

  repository "git://github.com/taksatou/dotfiles.git"
  reference "master"
  # action :sync
  action :checkout
end

bash "setup" do
  user node['user']['name']
  group node['user']['group']
  cwd node['user']['home']
  environment "HOME" => node['user']['home']

  code <<-EOC
    cd #{node['user']['home'] + "/misc/dotfiles"}
    bash init-env.sh
    cp .zshrc.include $HOME/.zshrc.include
  EOC
end
