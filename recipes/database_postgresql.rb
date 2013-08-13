#
# Cookbook Name:: gitlab-ci
# Recipe:: database_postgresql
#

postgresql = node['postgresql']
gitlab_ci = node['gitlab_ci']

# 5.Database
include_recipe "postgresql::server"
include_recipe "database::postgresql"

postgresql_connexion = {
  :host => 'localhost',
  :username => 'postgres',
  :password => postgresql['password']['postgres']
}

## Create a user for GitLab CI.
postgresql_database_user gitlab_ci['user'] do
  connection postgresql_connexion
  password gitlab_ci['database_password']
  action :create
end

## Create the GitLab CI database & grant all privileges on database
postgresql_database "gitlab_ci_#{gitlab_ci['env']}" do
  connection postgresql_connexion
  action :create
end

postgresql_database_user gitlab_ci['user'] do
  connection postgresql_connexion
  database_name "gitlab_ci_#{gitlab_ci['env']}"
  password gitlab_ci['database_password']
  action :grant
end
