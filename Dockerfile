FROM alpine:latest
MAINTAINER Marcos Machado <marcos.rafael.machado@gmail.com>
ARG tf_version="0.14.8"
ARG pk_version="1.7.0"
RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN apk add --no-cache --update \
    curl \
    unzip \
    bash \
    python3 \
    py-pip \
    git \
    openssh \
    make \
    libffi-dev \
    jq
RUN apk add dos2unix --update-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community/
RUN apk add --update tzdata
RUN pip install --upgrade pip
RUN pip install awscli
RUN pip install checkov
RUN curl https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip -o terraform_${tf_version}_linux_amd64.zip
RUN unzip terraform_${tf_version}_linux_amd64.zip -d /usr/local/bin && rm -f terraform_${tf_version}_linux_amd64.zip
RUN curl https://releases.hashicorp.com/packer/${pk_version}/packer_${pk_version}_linux_amd64.zip -o packer_${pk_version}_linux_amd64.zip
RUN unzip packer_${pk_version}_linux_amd64.zip -d /usr/local/bin && rm -f packer_${pk_version}_linux_amd64.zip
RUN ln -s /usr/local/bin/packer /usr/local/bin/packer-io

RUN mkdir -p /opt/workspace
RUN rm /var/cache/apk/*

WORKDIR /opt/workspace
CMD terraform version
