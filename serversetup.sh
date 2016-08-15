#!/bin/bash
echo "WELCOME KORDE OVER ALLE KORDE EVIG SEIER"
echo "--------------------------------------------------------------"
echo "Update apt-get packages"
echo
echo
echo
sudo apt-get update
echo "Installing pip3 python3 dev libpq"
echo
echo
echo
sudo apt-get install python3-pip python3-dev libpq-dev git htop
echo "Installing virtualenwrapper"
echo
echo
echo
sudo pip3 install virtualenv virtualenvwrapper
echo "adding shortcuts to .bashrc"
echo
echo
echo
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
echo "export WORKON_HOME=~/Env" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
echo "Installing uwsgi"
echo
echo
echo
sudo pip3 install uwsgi
echo "Setting up uwsgi sites"
sudo mkdir -p /etc/uwsgi/sites
cd /etc/uwsgi/sites
read -p "Enter sitename for uwsgi: " SITENAME
echo
read -p "Enter projectname for uwsgi, this should be the same as the project folder: " PROJNAME
echo
read -p "Enter ubuntu username for current user: " USER
echo
echo "[uwsgi]
project = $PROJNAME
base = /home/$USER
chdir = %(base)/%(project)
home = %(base)/Env/%(project)
module = %(project).wsgi:application
master = true
processes = 5
socket = %(base)/%(project)/%(project).sock
chmod-socket = 664
vacuum = true
" > $SITENAME.ini
echo "Adding uwsgi startup script"
echo
echo
echo
echo "
start on runlevel [2345]
stop on runlevel [!2345]
setuid $USER
setgid www-data
exec /usr/local/bin/uwsgi --emperor /etc/uwsgi/sites
" > /etc/init/uwsgi.conf
cd
echo "Installing nginx"
echo
echo
echo
sudo apt-get install nginx
echo "creating server script for ngninx port 80"
echo
echo
echo
read -p "Enter server name / domain name for nginx: " DOMAIN
echo
read -p "Enter domain ending eg: .no .com " DOMAINEND
echo 
echo "server {
    listen 80;
    server_name $DOMAIN$DOMAINEND www.$DOMAIN$DOMAINEND;
    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/$USER/$PROJNAME;
    }
    location / {
        include         uwsgi_params;
        uwsgi_pass      unix:/home/$USER/$PROJNAME/$PROJNAME.sock;
    }
}
" > /etc/nginx/sites-available/$SITENAME
echo "Linking sites enabled and available"
echo
echo
echo
sudo ln -s /etc/nginx/sites-available/$SITENAME /etc/nginx/sites-enabled
echo "Nginx configtest"
echo
echo
echo
sudo service nginx configtest



echo "Generate new ssh key"
echo
echo
read -p "Email for ssh key: " DOMAIN
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"


echo "Copying the ssh key"
echo
echo
echo


eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo
echo
echo
cat ~/.ssh/id_rsa.pub


echo "Setup script done, you should run: "
echo "source .bashrc"
echo "mkvirtualenv"
echo "sudo service nginx restart"
echo
echo "and"
echo
echo "sudo service uwsgi start"
echo "see: "
echo "https://www.digitalocean.com/community/tutorials/how-to-serve-django-applications-with-uwsgi-and-nginx-on-ubuntu-14-04"
echo "for complete guide"