GITRECEIVE_URL ?= https://raw.github.com/progrium/gitreceive/master/gitreceive

all: data/app_container/paas/jdk-7u40-linux-x64.gz dependencies .setup-git start-services enable-docker-api shipyard done

dependencies: /usr/local/bin/gitreceive /home/git/receiver /usr/bin/docker \
	        docker-app-container /usr/sbin/nginx /home/addkey /etc/dnsmasq.d/paas \
	        .install-binaries .install-services

clean:
	deluser git --remove-home
	deluser addkey --remove-home
	service stop upload-key
	service stop nginx-reloader
	service stop dnsmasq
	apt-get remove -y nginx dnsmask lxc-docker
	rm -f /usr/local/bin/uploadkeyd /etc/init.d/upload-key
	update-rc.d upload-key remove
	rm -f /usr/local/bin/nginx-reloaderd /etc/init.d/nginx-reloader
	update-rc.d nginx-reloader remove
	rm -f /usr/local/bin/upload-client-key /usr/local/bin/gitreceive
	rm -f .setup-git .install-services .install-binaries


.setup-git:
	@echo "Settingup the git user"
	cp -R data/git/ /home/
	hostname > /home/git/DOMAIN
	chown -R git /home/git
	@touch .setup-git

.install-services:
	@echo "Installing the upload key service"
	cp data/bin/uploadkeyd /usr/local/bin/
	cp data/etc/upload-key /etc/init.d/
	update-rc.d upload-key defaults
	@echo "Installing the nginx reloader service"
	cp data/bin/nginx-reloaderd /usr/local/bin/
	cp data/etc/nginx-reloader /etc/init.d/
	update-rc.d nginx-reloader defaults
	@touch .install-services

.install-binaries:
	@echo "Installing PAAS binaries"
	cp data/bin/upload-client-key /usr/local/bin/
	@touch .install-binaries

/home/addkey:
	adduser --disabled-login --system --shell /usr/local/bin/upload-client-key --gecos "" addkey

data/app_container/paas/jdk-7u40-linux-x64.gz:
	@echo "Unfortunately, this is a manual step"
	@echo "open your browser to http://www.oracle.com/technetwork/java/javase/downloads/index.html"
	@echo "and download the JDK7 for ubuntu 64 bits (e.g. 'jdk-7u40-linux-x64.gz')"
	@echo "then save it into the 'data/app_container/paas/' directory"
	@echo "then run:"
	@echo "sudo /bin/bash -c 'cd /root/paas && make'"


/usr/local/bin/gitreceive: 
	@echo "Installing gitreceive"
	wget -qO /usr/local/bin/gitreceive ${GITRECEIVE_URL}
	chmod +x /usr/local/bin/gitreceive


/home/git/receiver:
	@echo Initializing gitreceive
	gitreceive init

/usr/bin/docker:
	@echo "Installing docker"
	curl http://get.docker.io/gpg | apt-key add -
	grep 'http://get.docker.io/ubuntu docker' /etc/apt/sources.list.d/docker.list || echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
	apt-get update -y
	apt-get install -y lxc-docker
	-apt-get install -y linux-image-extra-`uname -r`

enable-docker-api:
	@echo "Enabling docker API to the world"
	grep '\-api\-enable\-cors \-H tcp://0.0.0.0:4243 \-H unix:///var/run/docker.sock' /etc/init/docker.conf || /bin/sh -c "sed -i 's/\-d/\-d \-api\-enable\-cors \-H tcp:\/\/0.0.0.0:4243 \-H unix:\/\/\/var\/run\/docker.sock/' /etc/init/docker.conf && initctl stop docker > /dev/null 2>&1 ; sleep 1 ; start docker"
	grep 'chmod 666 /var/run/docker.sock' /etc/rc.local >/dev/null || sed -i 's/exit 0/chmod 666 \/var\/run\/docker.sock\nexit 0/' /etc/rc.local
	sleep 5 && chmod 666 /var/run/docker.sock

/usr/sbin/nginx:
	@echo "Installing nginx"
	apt-get install -y nginx
	grep '# server_names_hash_bucket_size' /etc/nginx/nginx.conf || sed -i 's/# server_names_hash_bucket_size/server_names_hash_bucket_size/' /etc/nginx/nginx.conf
	echo "include /home/git/*/nginx.conf;" > /etc/nginx/conf.d/paas.conf


/etc/dnsmasq.d/paas:
	@echo "Installing dnsmasq"
	apt-get install -y dnsmasq
	echo "address=/.`hostname`/`ifconfig eth0 | grep 'inet addr' | cut -f2 -d: | cut -f1 -d' '`" > "/etc/dnsmasq.d/paas"

################################################################################

start-services:
	@echo "Starting the upload key service"
	/usr/sbin/service upload-key start
	@echo "Stating nging service"
	/usr/sbin/service nginx-reloader start
	/usr/sbin/service nginx start
	@echo "Starting dnsmasq service"
	/usr/sbin/service dnsmasq start

docker-app-container:
	@echo "Building the docker application conatiner"
	@docker images | grep hbouvier/ubuntu_paas || docker build -t hbouvier/ubuntu_paas .

shipyard:
	docker run -d -p :8000 ehazlett/shipyard

done:
	@echo
	@echo "Manual Steps on the `hostname` box:"
	@echo "    passwd addkey"
	@echo "   "
	@echo "Manual Steps on the the client box:"
	@echo "  cat ~/.ssh/id_rsa.pub | ssh addkey@`hostname`"

