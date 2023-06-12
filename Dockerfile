FROM docker.io/rockylinux:8-minimal

# Add repos and install smartmet-qdtools and clean cache
RUN microdnf -y upgrade && \
    microdnf -y install wget && \
    # microdnf doesn't yet support file based install so use wget and rpm
    # See https://github.com/rpm-software-management/microdnf/issues/20
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -O /tmp/epel-repo8.rpm && \
    rpm -i /tmp/epel-repo8.rpm && \
    wget https://download.fmi.fi/smartmet-open/rhel/8/x86_64/smartmet-open-release-latest-8.noarch.rpm -O /tmp/smartmet-repo8.rpm && \
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
    mkdir -p run/data/gfs/{bin,cnf}

VOLUME /smartmet/data/

COPY gfs-surface.st run/data/gfs/cnf/gfs-surface.st
COPY gfs-gribtoqd.cnf run/data/gfs/cnf/
COPY get_gfs.sh run/data/gfs/bin/get_gfs.sh

ENTRYPOINT [ "/bin/bash", "run/data/gfs/bin/get_gfs.sh" ]
