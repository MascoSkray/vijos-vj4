FROM ubuntu:xenial
MAINTAINER MascoSkray <MascoSkray@gmail.com>

# Update apt and install prerequisites
RUN apt-get update -y && apt-get install -y git curl && curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 && \
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list && \
apt-get update -y && apt-get install -y --force-yes python3-pip mongodb-org nodejs rabbitmq-server
# Clone the latest vj4 to local
RUN cd /home && git clone https://github.com/vijos/vj4.git
# Install requirements and build for production
RUN cd /home/vj4 && python3 -m pip3 install -r requirements.txt && npm install && \
curl "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz" | gunzip -c > GeoLite2-City.mmdb && \
npm run build:production && echo "\
#!/bin/sh\n\
cd /home/vj4\n\
python3 -m vj4.server --debug --listen http://0.0.0.0:8888\n\
\n" >/entrypoint.sh && chmod +x /entrypoint.sh

ENV LANG=C.UTF-8 TZ=Asia/Shanghai
EXPOSE 8888
CMD /entrypoint.sh
