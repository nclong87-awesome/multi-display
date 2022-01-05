FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive \
    NOVNC_SHA="1.3.0" \
    WEBSOCKIFY_SHA="0.10.0" \
    LOG_PATH=/var/log/supervisor

RUN apt-get -qqy update && apt-get -qqy --no-install-recommends install \
    curl \
    xvfb \
    x11vnc \
    openbox \
    wget \
    unzip \
    menu \
    net-tools \
    supervisor \
    chromium-browser

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - & \
    apt-get update && apt-get -y install nodejs npm


WORKDIR /app

RUN  wget -nv -O noVNC.zip "https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip" \
 && unzip -x noVNC.zip \
 && mv noVNC-${NOVNC_SHA} noVNC \
 && wget -nv -O websockify.zip "https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.zip" \
 && unzip -x websockify.zip \
 && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
 && rm websockify.zip noVNC.zip \
 && ln noVNC/vnc_auto.html noVNC/index.html \
 && sed -i "s/<number>4<\/number>/<number>1<\/number>/g" /etc/xdg/openbox/rc.xml

#RUN npm install -g nodemon
COPY package.json .
RUN npm install
COPY . .
RUN chmod -R +x supervisord.conf api

CMD /usr/bin/supervisord --configuration supervisord.conf
