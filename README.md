# PAAS

Base on Docker.io, gitreceive, git and Node.js, this is a small Platform As A Service for node.js application deployed in a node.js enviromnent

This is largely based on dokku, but without the buildpack from heroku which are too heavy for my need. I simply use a docker image that contains NVM to install the appropriate version of node.js before deploying the app

Dependencies:

    sudo apt-get install -y build-essential
    download the JDK and copy it under data/app_container/paas/

To build the docker image, used to run JAVA and Node.js application, you have to download the [jdk 1.7](http://www.oracle.com/technetwork/java/javase/downloads/index.html) __manually__
prior to run 'vagrant up', if running in vagrant or before running 'make' if installing bare metal. For this release, the scripts expect the JDK 1.7_40 for linux 64 bits (e.g. 'jdk-7u40-linux-x64.gz')
Once donwloaded, move into ./data/app_container/paas/' directory.

Once the installation is completed, you will have to set a password for the "addkey" user inside the vagrant box (or your bare bone machine):

    passwd addkey

And then from any machine where you want to use this PAAS, add your public by:

    cat ~/.ssh/id_rsa.pub | ssh addkey@__PAAS_HOST__

From that point you can push a new application onto the server using git:

    git remote add paas git@__PAAS_HOST__:__MyAppName__
    git push paas master
    open http://__MyAppName__.__PAAS_HOST__


## Dynamic Application Routing

On Mac OS X (Mountain Lion) here are the step I used to be able to use http://AppName.hostname/

Create a file with the name of your paas host (e.g. the default is paas.onprem) in /etc/resolver:

    /etc/resolver/paas.onprem

With the content:

    nameserver 127.0.0.1

Then install dnsmasq using MacPort

    sudo port install dnsmasq

Create a file with the name of your paas host (e.g. the default is paas.onprem) in cat /etc/dnsmasq.d

The content of the file should be in the form of

    address=/.hostname/ip-address/
    The default for the vagrant box should be:
    address=/.paas.onprem/10.0.0.2/
             ^- notice the starting dot!

Then update/flush the DNS:

    sudo killall -HUP mDNSResponder
    sudo launchctl unload -w /Library/LaunchDaemons/org.macports.dnsmasq.plist
    sudo launchctl load -w /Library/LaunchDaemons/org.macports.dnsmasq.plist
    sudo killall -HUP mDNSResponder
    sudo dscacheutil -flushcache


The real solution is to use a real DNS name and make the A record point to your paas box.

The worst solution is to use the PAAS box as you DNS.

The "not fun" solution is to use to figure out the external (semi-random) port number and use http://paas.onprem:semi_random_port/
