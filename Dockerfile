FROM oraclelinux:8
#FROM alpine

#arg1
ARG arg1

RUN echo $arg1

ENV env1=$arg1
#-------------------------------------------------------

#retry count argument
ARG retryCount

RUN echo $retryCount

ENV envRetryCount=$retryCount
#-------------------------------------------------------

#sync command
ARG syncCommandDataset

RUN echo $syncCommandDataset

ENV envSyncCommandDataset=$syncCommandDataset
#-------------------------------------------------------

RUN yum update

RUN yum install curl

RUN yum install unzip -y

RUN yum install sudo -y

COPY DatasetRefresh.sh /DatasetRefresh.sh

COPY retrySync.sh /retrySync.sh

COPY uniprotConfig.txt /uniprotConfig.txt

COPY rclone.conf /rclone.conf

CMD ["export", "env1"]

CMD ["export", "envRetryCount"]

CMD ["export", "envSyncCommandDataset"]

CMD ["/DatasetRefresh.sh"]