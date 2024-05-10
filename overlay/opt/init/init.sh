# configure system
sysctl -w vm.max_map_count=262144
echo vm.max_map_count=262144 | tee -a /etc/sysctl.conf
sysctl -w fs.file-max=65536
echo fs.file-max=65536 | tee -a /etc/sysctl.conf

# install and configure Docker
curl -fsSL get.docker.com -o /opt/init/get-docker.sh
chmod +x /opt/init/get-docker.sh
sh /opt/init/get-docker.sh
systemctl enable docker
systemctl start docker

# install and configure Nomad
curl https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip -o /opt/init/nomad.zip
unzip /opt/init/nomad.zip -d /opt/init/
cp /opt/init/nomad /usr/local/bin/nomad
chmod +x /usr/local/bin/nomad
systemctl daemon-reload
systemctl enable nomad
systemctl start nomad
