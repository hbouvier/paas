BOX_NAME   = ENV["BOX_NAME"]   || "punchaku"
BOX_URI    = ENV["BOX_URI"]    || "http://dl.dropbox.com/u/13510779/lxc-raring-amd64-2013-07-12.box"
BOX_DOMAIN = ENV["BOX_DOMAIN"] || "punchaku"
BOX_IP     = ENV["BOX_IP"]     || "10.0.0.2"
BOX_MEM    = ENV["BOX_MEM"]    || "4096"

Vagrant::configure("2") do |config|
  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI
  config.vm.synced_folder File.dirname(__FILE__), "/root/paas"
  config.vm.provision :shell, :inline => "apt-get -y install git && cd /root/paas && make all"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.hostname = "#{BOX_DOMAIN}"
  config.vm.network :private_network, ip: BOX_IP
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--memory", BOX_MEM]
  end
end
