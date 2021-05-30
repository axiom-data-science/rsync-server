ARG DOCKER_IMAGE=debian:buster-slim
FROM $DOCKER_IMAGE

LABEL author="Kyle Wilcox <kyle@axiomdatascience.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG BUILD_VERSION="1.0.0"
ENV BUILD_VERSION=$BUILD_VERSION

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

EXPOSE 22
EXPOSE 873

CMD ["rsync_server"]
ENTRYPOINT ["/entrypoint.sh"]

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bensuperpc/rsync-server"
LABEL org.label-schema.description="rsync server in docker"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.vendor="Bensuperpc"
LABEL org.label-schema.url="http://bensuperpc.com/"
LABEL org.label-schema.vcs-url="https://github.com/Bensuperpc/rsync-server"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.docker.cmd="docker build -t bensuperpc/rsync-server -f Dockerfile ."
