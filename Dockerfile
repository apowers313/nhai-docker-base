# base image: Ubuntu Bionic (18.04)
ARG OS_VER=bionic
FROM ubuntu:${OS_VER}

# setup environment
RUN mkdir -p /home/apowers
RUN mkdir -p /var/log/supervisord
WORKDIR /home/apowers
RUN apt update -y

# python
RUN apt install -y python3.8 python3-pip

# node
RUN apt install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs

# install redis server
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:redislabs/redis
RUN apt update -y
RUN apt install -y systemd redis
COPY ./rc.local /etc/rc.local
COPY ./redis.conf /etc/redis.conf
EXPOSE 6379

# redisgraph module
RUN mkdir -p /usr/lib/redis/modules
COPY ./redisgraph.Linux-ubuntu16.04-x86_64.2.4.11/redisgraph.so /usr/lib/redis/modules/redisgraph.so
RUN apt install -y libgomp1

# redisinsight
COPY ./redisinsight-linux64-1.10.1 /usr/bin/redisinsight
ENV RIPORT=8000
ENV RIHOST=0.0.0.0
ENV RIHOMEDIR=/var/run/redisinsight
ENV RILOGDIR=/var/log/redis
ENV RILOGLEVEL=INFO
#ADD ./redisinsight-app-dir.tgz /var/run/redisinsight
COPY ./redisinsight-app-dir /var/run/redisinsight
EXPOSE 8000

# jupyter
RUN pip3 install jupyter
COPY ./jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888

# jupyter extensions
RUN pip3 install jupyter_contrib_nbextensions
RUN pip3 install jupyter_nbextensions_configurator
RUN jupyter contrib nbextension install --user
RUN jupyter nbextensions_configurator enable --user
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable collapsible_headings/main

# ijavascript
RUN npm install -g ijavascript
RUN ijsinstall

# magicpatch
RUN npm install -g magicpatch
RUN magicpatch-install

# papermill
RUN pip3 install papermill
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# supervisor
RUN pip3 install supervisor
COPY ./supervisord.base.conf /usr/local/etc/supervisord.base.conf
EXPOSE 8080

# run server
CMD ["supervisord", "-c", "/usr/local/etc/supervisord.base.conf"]