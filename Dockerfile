# Use an official Ubuntu as a base image
FROM ubuntu:20.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Update the system and install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential libpcap-dev libpcre3-dev libnet1-dev zlib1g-dev luajit hwloc libdnet-dev \
    libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake cpputest libsqlite3-dev \
    uuid-dev libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev libluajit-5.1-dev libunwind-dev \
    wget git libtool autoconf automake net-tools iputils-ping nmap

# Step 2: Create a directory for Snort source files
WORKDIR /opt/snort-source-files

# Step 3: Install LibDAQ
RUN git clone https://github.com/snort3/libdaq.git && \
    cd libdaq && \
    ./bootstrap && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# Step 4: Install Tcmalloc
RUN cd /opt/snort-source-files && \
    wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.13/gperftools-2.13.tar.gz && \
    tar xzf gperftools-2.13.tar.gz && \
    cd gperftools-2.13/ && \
    ./configure && \
    make && \
    make install

# Step 5: Install Snort 3
RUN cd /opt/snort-source-files && \
    git clone https://github.com/snort3/snort3.git && \
    cd snort3/ && \
    ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc && \
    cd build && \
    make && \
    make install && \
    ldconfig && \
    ln -s /usr/local/bin/snort /usr/sbin/snort

# Step 6: Verify Snort installation (Optional)
# RUN snort -V

# Set the default command to show the snort version
CMD ["/bin/bash"]
