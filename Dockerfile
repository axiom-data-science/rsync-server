FROM debian:buster
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV NOTVISIBLE "in users profile"

RUN apt-get update && \
	apt-get install -y openssh-server rsync && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

COPY entrypoint.sh /entrypoint.sh
RUN chmod 744 /entrypoint.sh

ENV USERNAME='admin'
ENV PASSWORD='mysecret'
ENV ALLOW='10.0.0.0/8 172.16.0.0/12 192.168.0.0/16'
ENV VOLUME='/data'

VOLUME [ "/data" ]

EXPOSE 22
EXPOSE 873

CMD ["rsync_server"]
ENTRYPOINT ["/entrypoint.sh"]
