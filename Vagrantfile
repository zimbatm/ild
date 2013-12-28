# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "base-0.4.0"
  config.vm.box_url = "http://paasta-boxes.s3.amazonaws.com/base-0.4.0-amd64-20131218-virtualbox.box"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end 

  config.vm.network "forwarded_port", guest: 4243, host: 4243

  # Install docker
  config.vm.provision "shell", inline: <<EOF
export DEBIAN_FRONTEND=noninteractive
wget -O - https://get.docker.io/gpg | apt-key add -
echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:4243 -api-enable-cors"' > /etc/default/docker
apt-get update -q
apt-get install -qy lxc-docker
usermod -G docker vagrant
EOF
  # Install ruby 2.0
  config.vm.provision "shell", inline: <<EOF
mkdir -p /usr/local/src
cd /usr/local/src
wget -O ruby-install-0.3.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.3.3.tar.gz
tar -xzvf ruby-install-0.3.3.tar.gz
cd ruby-install-0.3.3/
make install
hash -r
ruby-install -i /usr/local/ ruby 2.0
su -c "gem install bundler --no-ri --no-rdoc --user" vagrant
echo 'PATH=$HOME/.gem/ruby/2.0.0/bin:$PATH' >> /home/vagrant/.profile
EOF

end
