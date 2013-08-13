#
# Cookbook Name:: gitlab-ci
# Recipe:: install
#

gitlab_ci = node['gitlab_ci']

include_recipe "gitlab-ci::database_#{gitlab_ci['database_adapter']}"
include_recipe "gitlab-ci::gitlab-ci"
include_recipe "gitlab-ci::nginx"
