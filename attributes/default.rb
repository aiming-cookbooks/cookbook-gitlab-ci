# Package
if platform_family?("rhel")
  packages = %w{
    libicu-devel
  }
else
  packages = %w{
    wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev
    libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential
    zlib1g-dev openssh-server git-core libyaml-dev libpq-dev libicu-dev
    redis-server 
  }
end

default['gitlab_ci']['packages'] = packages
default['gitlab_ci']['ruby'] = "2.0.0-p353"

# User
default['gitlab_ci']['user'] = "gitlab_ci"
default['gitlab_ci']['group'] = "gitlab_ci"
default['gitlab_ci']['home'] = "/home/gitlab_ci"

# GitLab CI
default['gitlab_ci']['repository'] = "git://github.com/gitlabhq/gitlab-ci.git"
default['gitlab_ci']['revision'] = "v3.2.0"
default['gitlab_ci']['path'] = "/home/gitlab_ci/gitlab_ci"

# GitLab CI config
default['gitlab_ci']['gitlab_hosts'] = ['https://localhost']
default['gitlab_ci']['host'] = "localhost"
default['gitlab_ci']['port'] = "80"

# Gems
default['gitlab_ci']['bundle_install'] = "bundle install --path=.bundle --deployment"
default['gitlab_ci']['env'] = "production"

node.default['gitlab_ci']['database_adapter'] = 'mysql'

# nginx setting
node.default['nginx']['default_site_enabled'] = false
node.default['nginx']['version'] = '1.4.4'
node.default['nginx']['repo_source'] = 'nginx'

# redisio setting
#
node.default['redisio']['mirror'] = 'http://download.redis.io/releases'
node.default['redisio']['version'] = '2.8.4'
