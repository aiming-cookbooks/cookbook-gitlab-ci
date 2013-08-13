#
# Cookbook Name:: gitlab-ci
# Recipe:: gitlab_ci
#

gitlab_ci = node['gitlab_ci']

# 6. GitLab CI
## Clone the Source
git gitlab_ci['path'] do
  repository gitlab_ci['repository']
  revision gitlab_ci['revision']
  user gitlab_ci['user']
  group gitlab_ci['group']
  action :sync
end

## Configure it
### Copy the example GitLab CI config
template File.join(gitlab_ci['path'], 'config', 'application.yml') do
  source "application.yml.erb"
  user gitlab_ci['user']
  group gitlab_ci['group']
  variables({
    :gitlab_hosts => gitlab_ci['gitlab_hosts'],
  })
end

### Make sure GitLab CI can write to the log/ and tmp/ directories
%w{log tmp}.each do |path|
  directory File.join(gitlab_ci['path'], path) do
    owner gitlab_ci['user']
    group gitlab_ci['group']
    mode 0755 
  end
end

### Create directories for sockets/pids and make sure GitLab CI can write to them
%w{tmp/pids tmp/sockets}.each do |path|
  directory File.join(gitlab_ci['path'], path) do
    owner gitlab_ci['user']
    group gitlab_ci['group']
    mode 0755 
  end
end

### Copy the example Puma config
template File.join(gitlab_ci['path'], "config", "puma.rb") do
  source "puma.rb.erb"
  user gitlab_ci['user']
  group gitlab_ci['group']
  variables({
    :path => gitlab_ci['path'],
    :env => gitlab_ci['env']
  })
end

### Configure Git global settings for git user, useful when editing via web
bash "git config" do
  code <<-EOS
    git config --global user.name "GitLab CI"
    git config --global user.email "gitlab_ci@#{gitlab_ci['host']}"
  EOS
  user gitlab_ci['user']
  group gitlab_ci['group']
  environment('HOME' => gitlab_ci['home'])
end

## Configure GitLab CI DB settings
template File.join(gitlab_ci['path'], "config", "database.yml") do
  source "database.yml.#{gitlab_ci['database_adapter']}.erb"
  user gitlab_ci['user']
  group gitlab_ci['group']
  variables({
    :user => gitlab_ci['user'],
    :password => gitlab_ci['database_password']
  })
end

template File.join(gitlab_ci['home'], ".gemrc") do
  source "gemrc.erb"
  user gitlab_ci['user']
  group gitlab_ci['group']
  notifies :run, "execute[bundle install]", :immediately
end

### without
bundle_without = []
case gitlab_ci['database_adapter']
when 'mysql'
  bundle_without << 'postgres'
when 'postgresql'
  bundle_without << 'mysql'
end

case gitlab_ci['env']
when 'production'
  bundle_without << 'development'
  bundle_without << 'test'
else
  bundle_without << 'production'
end

execute "bundle install" do
  command "#{gitlab_ci['bundle_install']} --without #{bundle_without.join(" ")}"
  cwd gitlab_ci['path']
  user gitlab_ci['user']
  group gitlab_ci['group']
  action :nothing
end

### db:setup
execute "rake db:setup" do
  command "bundle exec rake db:setup RAILS_ENV=#{gitlab_ci['env']}"
  cwd gitlab_ci['path']
  user gitlab_ci['user']
  group gitlab_ci['group']
  not_if {File.exists?(File.join(gitlab_ci['home'], ".gitlab_ci_setup"))}
end

file File.join(gitlab_ci['home'], ".gitlab_ci_setup") do
  owner gitlab_ci['user']
  group gitlab_ci['group']
  action :create
end

### db:migrate
execute "rake db:migrate" do
  command "bundle exec rake db:migrate RAILS_ENV=#{gitlab_ci['env']}"
  cwd gitlab_ci['path']
  user gitlab_ci['user']
  group gitlab_ci['group']
  not_if {File.exists?(File.join(gitlab_ci['home'], ".gitlab_ci_migrate"))}
end

file File.join(gitlab_ci['home'], ".gitlab_ci_migrate") do
  owner gitlab_ci['user']
  group gitlab_ci['group']
  action :create
end

### schedules
execute "schedules" do
  command "bundle exec whenever -w RAILS_ENV=#{gitlab_ci['env']}"
  cwd gitlab_ci['path']
  user gitlab_ci['user']
  group gitlab_ci['group']
  not_if {File.exists?(File.join(gitlab_ci['home'], ".gitlab_ci_schedules"))}
end

file File.join(gitlab_ci['home'], ".gitlab_ci_schedules") do
  owner gitlab_ci['user']
  group gitlab_ci['group']
  action :create
end

## Install Init Script
template "/etc/init.d/gitlab_ci" do
  source "initd.erb"
  mode 0755
  variables({
    :path => gitlab_ci['path'],
    :user => gitlab_ci['user'],
    :env => gitlab_ci['env']
  })
end

## Start Your GitLab CI Instance
service "gitlab_ci" do
  supports :start => true, :stop => true, :restart => true, :status => true
  action :enable
end

file File.join(gitlab_ci['home'], ".gitlab_ci_start") do
  owner gitlab_ci['user']
  group gitlab_ci['group']
  action :create_if_missing
  notifies :start, "service[gitlab_ci]"
end
