#
# Cookbook Name:: gitlab_ci
# Recipe:: database_mysql
#

mysql = node['mysql']
gitlab_ci = node['gitlab_ci']

# 5.Database
include_recipe "mysql::server"
include_recipe "database::mysql"

mysql_connexion = {
  :host => 'localhost',
  :username => 'root',
  :password => mysql['server_root_password']
}

## Create a user for GitLab CI.
mysql_database_user gitlab_ci['user'] do
  connection mysql_connexion
  password gitlab_ci['database_password']
  action :create
end

## Create the GitLab CI database & grant all privileges on database
mysql_database "gitlab_ci_#{gitlab_ci['env']}" do
  connection mysql_connexion
  action :create
end

mysql_database_user gitlab_ci['user'] do
  connection mysql_connexion
  password gitlab_ci['database_password']
  database_name "gitlab_ci_#{gitlab_ci['env']}"
  host 'localhost'
  privileges [:select, :update, :insert, :delete, :create, :drop, :index, :alter]
  action :grant
end
