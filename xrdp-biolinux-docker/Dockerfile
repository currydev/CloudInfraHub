# Use Ubuntu 18.04 as base image
FROM ubuntu:18.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ARG host_name="Challenger"
ENV HOSTNAME=$host_name

# Update and install essential packages
RUN apt-get update && apt-get install -y \
    ibus-mozc language-pack-ja-base language-pack-ja fonts-takao \
    openssl sudo xrdp xfce4 xfce4-terminal xfce4-goodies openssh-server supervisor \
    git tig gedit nano wget curl net-tools firefox build-essential software-properties-common

# Set locale and timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configure user
ARG root_password="super"
ARG user_name="my-ubuntu"
ARG user_password="my-Password"
RUN echo root:$root_password | chpasswd && \
    useradd -m -G sudo $user_name -p $(openssl passwd -1 $user_password) --shell /bin/bash

# Configure RDP and SSH
RUN adduser xrdp ssl-cert && mkdir /var/run/sshd
COPY ./config/xrdp/* /etc/xrdp/
COPY ./config/ssh/* /etc/ssh/
COPY ./config/ssh/.ssh/id_rsa.pub /home/$user_name/.ssh/authorized_keys
EXPOSE 3389 22

# Set up supervisor
ADD ./config/supervisord/* /etc/supervisor/conf.d/

# Clean up
RUN apt-get clean && apt-get autoremove && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

CMD ["bash", "-c", "/usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]
