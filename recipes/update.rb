#
# Cookbook Name:: gitlab_ci
# Recipe:: update
#

gitlab_ci = node['gitlab_ci']

service "gitlab_ci" do
  action :stop
end

file File.join(gitlab_ci['home'], ".gitlab_ci_start") do
  action :delete
end

file File.join(gitlab_ci['home'], ".gemrc") do
  action :delete
end

file File.join(gitlab_ci['home'], ".gitlab_ci_migrate") do
  action :delete
end
