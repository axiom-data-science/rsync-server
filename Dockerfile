FROM debian:jessie
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    rsync \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 873

CMD ["rsync_server"]
ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /entrypoint.sh
RUN chmod 744 /entrypoint.sh
