# Installing Jupyterhub

1. Install a recent Ubuntu. I am using 18.04.2

2. Update/Upgrade

```
sudo apt-get update
sudo apt-get upgrade -y
```

3. Install docker and docker-compose and certbot (letsencrypt)

```
sudo apt-get install -y docker docker-compose certbot make
```

3.1. Add yourself to the docker group

```
sudo adduser `whoami` docker
```


4. [OPTIONAL] create a new LV to put all the docker storage in:

```
VG=`sudo vgs -o name --noheadings`
sudo lvcreate -l 100%FREE --name docker $VG
sudo mkfs.ext4 /dev/$VG/docker
echo "/dev/$VG-docker /var/lib/docker ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo systemctl stop docker
sudo mount /var/lib/docker
sudo systemctl start docker
```

OR

```
# cat > /etc/docker/daemon.json << EOF
{
 "graph": "/local/data/docker"
}
EOF
# rsync -aP /var/lib/docker/ /local/data/docker
# mv /var/lib/docker /var/lib/docker.old
# service docker start
```

4. Get letsencrypt and get some certs

```
sudo letsencrypt certonly --standalone
```

and follow the prompts.

4. Clone the repository

```
git clone https://github.com/jonludlam/jupyterhub-deploy-docker
cd jupyterhub-deploy-docker
```

Add the cert/key from letsencrypt:

```
sudo ln -s /etc/letsencrypt/live/<my DNS name>/cert.pem letsencrypt/cert.pem
sudo ln -s /etc/letsencrypt/live/<my DNS name>/privkey.pem letsencrypt/privkey.pem
```


5. Register a new application on github:

Go to https://github.com/settings/applications/new and fill out the details

and create a file in secrets called `oauth.env`, with the following contents:

```
GITHUB_CLIENT_ID=<client id>
GITHUB_CLIENT_SECRET=<secret> 
OAUTH_CALLBACK_URL=https://<my DNS name/hub/oauth_callback
```

6. Run `make`

```
make
```

7. Build the student and instructor hub images

```
cd hub
docker build . -t hub
```

```
cd studenthub
docker build . -t studenthub
```

8. Start the jupyterhub server

```
cd ../jupyterhub-deploy-docker
docker-compose up -d
```

