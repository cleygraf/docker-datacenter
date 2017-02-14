#!/bin/bash
echo ""
echo "=============================================================="
echo "=============================================================="
echo ""
echo "$0 started"
echo ""

# install docker cs
cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum install docker-engine -y


# start docker service
systemctl enable docker.service
sudo service docker start

#  allow vagrant user to run docker commands
sudo usermod -a -G docker vagrant
sudo chown -R vagrant:root /var/lib/docker/
sudo chown -R vagrant:root /etc/docker/

# docker compose
curl -Ls https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > docker-compose
sudo mv docker-compose /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chown root:docker /usr/local/bin/docker-compose

# discover the docker ips
# docker has an issue with trying to join
# via a hacked /etc/hosts entry
cat <<EOF | sudo tee -a /etc/hosts > /dev/null
${DOCKER1_IP} dtr.local
EOF

echo ""
echo "$0 finished"
echo ""
echo "=============================================================="
echo "=============================================================="
echo ""
