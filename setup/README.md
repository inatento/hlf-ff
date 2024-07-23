=========================================================
# Instalacion de las dependencias necesarias para
# desplegar una red de fabric y descargar el entorno de firefly
==========================================================
Entrar a la carpeta "setup" para desde ahí ejecutar los comandos necesarios:
> cd /setup
> chmod 755 *.sh

sudo ./update_etc_hosts.sh

1. Install Docker
sudo  ./docker.sh
exit

* Log back y log in para validad la instalación de docker

docker info

2. Install GoLang
sudo  ./go.sh

* Log back in to the VM & check GoLang version

exit
go version

# NOTA: Si no arroja resultados el comando "go version" ejecutar:
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc 
source ~/.bashrc

3. Install the JQ tool
sudo ./jq.sh

4. Instalar firefly
sudo tar -zxf firefly-cli_*.tar.gz -C /usr/local/bin ff

5. Setup Fabric
sudo -E   ./ff_fabric_setup.sh
exit
# NOTA: Si no arroja resultados el comando "peer version" ejecutar:
echo "export PATH=$PATH:$HOME/fabric-samples/bin" >> ~/.profile
source ~/.profile
echo "export PATH=$PATH:$HOME/fabric-samples/bin" >> ~/.bashrc 
source ~/.bashrc


6. Validate the setup
    ./validate-prereqs.sh

===============================================================
# Issues?
# Run the following script and share it with Raj in course Q&A
===============================================================
Log into the VM
> vagrant ssh
> cd /vagrant/setup
> ./validate-all.sh  > report.txt

Copy & paste the content of report.txt to Q&A post or email.