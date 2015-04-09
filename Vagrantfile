# Commands required to setup working docker enviro, link
# containers etc.
$setup = <<SCRIPT
# Stop and remove any existing containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Build containers from Dockerfiles
docker build -t postgres /app/docker/postgres
docker create -v /calcentral_config:/calcentral_config --name config postgres
docker build -f /app/Dockerfile.gulp -t gulp /app
docker build -t rails /app

# Run and link the containers
docker run -d --name postgres -e POSTGRESQL_DB=calcentral_development -e POSTGRESQL_USER=calcentral_development -e POSTGRESQL_PASS=secret postgres:latest
docker run -d --name gulp -v /app:/app gulp:latest
docker run -e "RAILS_ENV=$1" -e "CALCENTRAL_CONFIG_DIR=/calcentral_config" --volumes-from gulp --volumes-from config -d -p 3000:3000 -v /app:/app --link postgres:db --name rails rails:latest

SCRIPT

# Commands required to ensure correct docker containers
# are started when the vm is rebooted.
$start = <<SCRIPT
docker start postgres
docker start rails
docker start gulp
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|

  # Setup resource requirements
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # need a private network for NFS shares to work
  config.vm.network "private_network", ip: "192.168.50.4"

  # Rails Server Port Forwarding
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  # Ubuntu
  config.vm.box = "ubuntu/trusty64"

  # Install latest docker
  config.vm.provision "docker"

  # Must use NFS for this otherwise rails
  # performance will be awful
  config.vm.synced_folder ".", "/app", type: "nfs", mount_options: ['nolock,vers=3,udp,noatime,actimeo=1']
  config.vm.synced_folder "~/.calcentral_config", "/calcentral_config", type: "nfs", mount_options: ['nolock,vers=3,udp,noatime,actimeo=1']

  # Setup the containers when the VM is first
  # created
  RAILS_ENV = ENV['RAILS_ENV'] || "development"
  config.vm.provision "shell", inline: $setup, args: RAILS_ENV

  # Make sure the correct containers are running
  # every time we start the VM.
  config.vm.provision "shell", run: "always", inline: $start
end
