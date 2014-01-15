
#
# Cookbook Name:: gitlab-ci
# Recipe:: default
#

include_recipe "yum-remi" if platform?("centos")
include_recipe "postfix"
include_recipe "gitlab-ci::initial"
include_recipe "gitlab-ci::install"
