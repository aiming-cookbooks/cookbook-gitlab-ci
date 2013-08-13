name             'gitlab-ci'
maintainer       'ogom'
maintainer_email 'ogom@outlook.com'
license          'MIT'
description      'Installs/Configures GitLab CI'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe "gitlab::initial", "Setting the initial"
recipe "gitlab::install", "Installation"

%w{redisio ruby_build postgresql mysql database yum}.each do |dep|
  depends dep
end

%w{debian ubuntu centos}.each do |os|
  supports os
end
