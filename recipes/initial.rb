#
# Cookbook Name:: gitlab-ci
# Recipe:: initial
#

gitlab_ci = node['gitlab_ci']

# 0. Initial Change
directory "/tmp" do
  mode 0777
end


# 1. Packages / Dependencies
include_recipe "apt" if platform?("ubuntu", "debian")
include_recipe "yum::epel" if platform?("centos")
include_recipe "redisio::install"
include_recipe "redisio::enable"

## Install the required packages.
gitlab_ci['packages'].each do |pkg|
  package pkg
end


# 2. Ruby
include_recipe "ruby_build"

## Download and compile it:
ruby_build_ruby gitlab_ci['ruby'] do
  prefix_path "/usr/local/"
end

## Install the Bundler Gem:
gem_package "bundler" do
  gem_binary "/usr/local/bin/gem"
  options "--no-ri --no-rdoc"
end


# 3. System Users
## Create user for Gitlab.
user gitlab_ci['user'] do
  comment "GitLab"
  home gitlab_ci['home']
  shell "/bin/bash"
  supports :manage_home => true
end

user gitlab_ci['user'] do
  action :lock
end
