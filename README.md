# PAAS

Base on Docker.io, gitreceive, git and Node.js, this is a small Platform As A Service for node.js application deployed in a node.js enviromnent

This is largely based on dokku, but without the buildpack from heroku which are too heavy for my need. I simply use a docker image that contains NVM to install the appropriate version of node.js before deploying the app

To build the docker image, used to run JAVA and Node.js application, you have to download the [jdk 1.7](http://www.oracle.com/technetwork/java/javase/downloads/index.html) __manually__
prior to run 'vagrant up', if running in vagrant or before running 'make' if installing bare metal. For this release, the scripts expect the JDK 1.7_40 for linux 64 bits (e.g. 'jdk-7u40-linux-x64.gz')
Once donwloaded, move into ./data/app_container/paas/' directory.

Once the installation is completed, you will have to set a password for the "addkey" user inside the vagrant box (or your bare bone machine):

    passwd addkey

And then from any machine where you want to use this PAAS, add your public by:

    cat ~/.ssh/id_rsa.pub | ssh addkey@__PAAS_HOST__ upload-client-key
    
From that point you can push a new application onto the server using git:

    git remote add paas git@__PAAS_HOST__:__MyAppName__
    git push paas master
    open http://__MyAppName__.__PAAS_HOST__
    
    
