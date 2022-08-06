#### Local Quick Setup for Prometheus Server

    1. Vagrant:

            - Install Vagrant from https://www.vagrantup.com/
            - Install VirtualBox or change the provider accordingly
            - Go Inside setup directory and change the ip's in Vagrantfile accordingly 
            - Run vagrant up from inside the setup directory where the Vagrantfile is present
            - Go to http://<prometheus_node_ip>:9090/
            - Once done, vagrant destroy --force

    2. Docker-Compose:

            - Install Docker and docker-compose 
            - Start the docker daemon
            - Go Inside docker-prom directory 
            - Run docker-compose up --build from inside the docker-prom directory where the docker-compose.yml is present
            - Go to http://localhost:9090/
            - Once done, docker-compose down


