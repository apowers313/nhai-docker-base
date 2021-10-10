# base image: Ubuntu Bionic (18.04)
ARG OS_VER=bionic
FROM ubuntu:${OS_VER}

# setup environment
RUN mkdir -p /home/apowers
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
#apt install -y systemd
COPY ./rc.local /etc/rc.local
COPY ./redis.conf /etc/redis.conf
EXPOSE 6379

# redisgraph module
RUN mkdir -p /usr/lib/redis/modules
COPY ./redisgraph.Linux-ubuntu16.04-x86_64.2.4.11/redisgraph.so /usr/lib/redis/modules/redisgraph.so
RUN apt install -y libgomp1

# jupyter
RUN pip3 install jupyter
COPY ./jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888

# ijavascript
RUN npm install -g ijavascript
RUN ijsinstall

# magicpatch
RUN npm install -g magicpatch
RUN magicpatch-install

# papermill
RUN pip3 install papermill

# supervisor
RUN pip3 install supervisor
COPY ./supervisord.base.conf /usr/local/etc/supervisord.base.conf
EXPOSE 8080

# run server
CMD ["supervisord", "-c", "/usr/local/etc/supervisord.base.conf"]