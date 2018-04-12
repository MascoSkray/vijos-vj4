FROM debian:jessie
MAINTAINER MascoSkray <MascoSkray@gmail.com>

# Update apt and install prerequisites
RUN apt-get update -y && apt-get install -y git python3-pip python3-dev mongodb nodejs rabbitmq-server
# Clone the latest vj4 to local
RUN cd /home && git clone https://github.com/vijos/vj4.git
# Install requirements and build for production
RUN cd /home/vj4 && python3 -m pip install -r requirements.txt && npm install && \
curl "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz" | gunzip -c > GeoLite2-City.mmdb && \
npm run build:production && echo "\
#!/bin/sh\n\
cd /home/vj4\n\
python3 -m vj4.server --debug --listen http://0.0.0.0:8888\n\
\n" >/entrypoint.sh && chmod +x /entrypoint.sh

ENV LANG=C.UTF-8 TZ=Asia/Shanghai
EXPOSE 8888
CMD /entrypoint.sh

