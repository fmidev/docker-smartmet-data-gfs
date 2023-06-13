FROM docker.io/rockylinux:8-minimal
LABEL license "MIT License Copyright (c) 2023 FMI Open Development"

# Add repos and install smartmet-qdtools and clean cache
RUN microdnf -y upgrade && \
    # Install useradd groupadd
    microdnf -y install shadow-utils && \
    # microdnf doesn't yet support file/url based install so use curl and rpm
    # See https://github.com/rpm-software-management/microdnf/issues/20
    curl -L -o /tmp/epel-repo8.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    rpm -i /tmp/epel-repo8.rpm && \
    curl -L -o /tmp/smartmet-repo8.rpm https://download.fmi.fi/smartmet-open/rhel/8/x86_64/smartmet-open-release-latest-8.noarch.rpm && \
    rpm -i /tmp/smartmet-repo8.rpm && \
    microdnf -y install rsync pbzip2 && \
    microdnf -y module disable postgresql:12 && \
    microdnf -y install smartmet-qdtools --enablerepo=powertools && \
    # Clean files
    rm -f /tmp/epel-repo8.rpm /tmp/smartmet-repo8.rpm && \
    microdnf clean all && rm -rf /var/cache/{dnf,yum}

WORKDIR /smartmet/

RUN mkdir -p .cnf/data && \
    mkdir -p tmp/data/gfs && \
    mkdir -p logs/data && \
    mkdir -p run/data/gfs/{bin,cnf} && \
    # Add volume location for chown
    mkdir -p /smartmet/data

COPY gfs-surface.st run/data/gfs/cnf/gfs-surface.st
COPY gfs-gribtoqd.cnf run/data/gfs/cnf/
COPY get_gfs.sh run/data/gfs/bin/get_gfs.sh

RUN groupadd -r data-gfs && useradd -r -g data-gfs data-gfs && \
    chown -R data-gfs:data-gfs /smartmet

VOLUME /smartmet/data/
USER data-gfs
ENTRYPOINT [ "/bin/bash", "run/data/gfs/bin/get_gfs.sh" ]
