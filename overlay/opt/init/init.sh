mkdir -p /opt/init
curl https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip -o /opt/init/nomad.zip
unzip /opt/init/nomad.zip -d /opt/init/
cp /opt/init/nomad /usr/local/bin/nomad
chmod +x /usr/local/bin/nomad
systemctl daemon-reload
systemctl enable nomad
systemctl start nomad
