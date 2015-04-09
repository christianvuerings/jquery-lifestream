#CalCentral with Vagrant

##Overview

Our Vagrant environment has 2 layers. First, Vagrant automates the startup & shutdown of a virtual machine that
runs Linux. Inside this virtual machine, Docker is used to automate the startup of "containers" that run the
Rails and postgres applications. [This article](http://www.talkingquickly.co.uk/2014/06/rails-development-environment-with-vagrant-and-docker/)
was used as the core of our Vagrant/Docker setup, and has a lot of helpful background information about how Vagrant
and Docker work. You should also read and understand the [Docker user guide](https://docs.docker.com/userguide/) as the
Docker container way of doing things can often be counterintuitive.

##New developer setup
1. Install Vagrant https://www.vagrantup.com/downloads.html
1. Install VirtualBox  https://www.virtualbox.org/wiki/Downloads
1. Install vagrant-vbguest (to keep guest additions up to date):

  ```
  vagrant plugin install vagrant-vbguest
  ```
1. Start vagrant:

  ```
  vagrant up
  ```

  Your first “vagrant up” will take a half hour or so, as it has to download a lot of materials (OS, Rubies, etc etc)
  Your firewall may hassle you to grant permission to necessary daemons (/etc/nfsd and others). Answer Yes, or else your NFS mount from host to guest will not work.
  You may also get prompted to enter your admin password (again, so NFS will work). Do so.
1. See the app running at http://localhost:3000/

## Developer workflow

The "./d" script is called from your host machine. It uses "vagrant ssh" to get inside the Vagrant virtual machine,
where it then runs commands inside the "rails" docker container using "docker run" scripts located in ./docker/scripts. Going
through "./d" is the preferred way of interacting with the Docker container for most rails-related things.

1. Restart rails (runs bundle install and creates/seeds/migrates database if needed):

  ```
  ./d restart
  ```
1. Rebuild rails (takes longer than restart, but everything in the rails Docker container gets refreshed):

  ```
  ./d rebuild
  ```
1. Tail rails logs:

  ```
  ./d logs
  ```
1. Get a rails console inside the rails docker container:

  ```
  ./d rc
  ```
1. Run an arbitrary shell command inside the rails container:

  ```
  ./d cmd "bundle exec rake something:something"
  ```
1. Get a bash shell inside the rails container and run tests in it:

  ```
  ./d cmd bash
  bundle exec rake spec       # <-- this is inside Ubuntu guest VM
  ```
1. Shut down the vagrant VM:

  ```
  vagrant halt
  ```
1. Re-provision vagrant (which gets a fresh blank Postgres instance and fresh gulp build):

  ```
  vagrant provision
  ```
1. Wipe your vagrant VM clean and rebuild from scratch (drastic):

  ```
  vagrant destroy
  vagrant up
  ```
1. See what's going on inside gulp:

  ```
  vagrant ssh
  docker logs -f gulp       # <-- this is inside Ubuntu guest VM
  ```
1. See what's going on inside postgres:

  ```
  vagrant ssh
  docker logs -f postgres       # <-- this is inside Ubuntu guest VM
  ```
1. Refresh your client-side assets:

  ```
  rm -rf node_modules/ public/assets/ ; vagrant provision
  ```

## CalCentral Configuration

The Vagrant environment knows about your ~/.calcentral_config directory on your host PC and will make it available
to the guest VM automatically.
