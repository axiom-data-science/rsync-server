FROM debian:bullseye-slim
LABEL org.opencontainers.image.authors="Kyle Wilcox <kyle@axds.co>" \
      org.opencontainers.image.url="https://github.com/axiom-data-science/rsync-server"
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV NOTVISIBLE "in users profile"

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server rsync && \
    apt-get clean && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /entrypoint.sh

EXPOSE 22
EXPOSE 873

ENTRYPOINT ["/entrypoint.sh"]
CMD ["rsync_server"]
