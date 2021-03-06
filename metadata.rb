name             'gitlab-ci'
maintainer       'ogom'
maintainer_email 'ogom@outlook.com'
license          'MIT'
description      'Installs/Configures GitLab CI'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

recipe "gitlab-ci::initial", "Setting the initial"
recipe "gitlab-ci::install", "Installation"

%w{redisio ruby_build postgresql mysql database yum yum-epel nginx postfix}.each do |dep|
  depends dep
end

%w{debian ubuntu centos}.each do |os|
  supports os
end
