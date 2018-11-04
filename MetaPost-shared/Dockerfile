
# Base image
FROM ubuntu:16.04
MAINTAINER Paul Murrell <paul@stat.auckland.ac.nz>

RUN apt-get update && \
    apt-get install -y \
        subversion

# Checkout MetaPost source
RUN mkdir /opt/MetaPost && \
    cd /opt/MetaPost && \
    svn co --username anonsvn --password anonsvn --trust-server-cert https://serveur-svn.lri.fr/svn/modhel/metapost/trunk 

# Build MetaPost
RUN apt-get update && \
    apt-get install -y \
        gcc \
        g++ \
        make \
        texinfo
RUN cd /opt/MetaPost/trunk/ && \
    CFLAGS=-fpic ./build.sh

# Build MetaPost shared library
RUN cd /opt/MetaPost/trunk/build/texk/web2c && \
    gcc -shared -o libmplib.so libmplib*.o mplibdir/libmputil*.o \
        -L/opt/MetaPost/trunk/build/libs/libpng -lpng \
        -L/opt/MetaPost/trunk/build/libs/cairo -lcairo \
        -L/opt/MetaPost/trunk/build/libs/pixman -lpixman \
        -L/opt/MetaPost/trunk/build/libs/mpfr -lmpfr \
        -L/opt/MetaPost/trunk/build/libs/gmp -lgmp \ 
        -L/opt/MetaPost/trunk/build/texk/kpathsea/.libs -lkpathsea \
        -L/opt/MetaPost/trunk/build/libs/zlib -lz \
        -lm

# INSTALL MetaPost shared library 
RUN cp /opt/MetaPost/trunk/build/texk/web2c/libmplib.so /usr/lib && \
    cp /opt/MetaPost/trunk/build/texk/web2c/mplib.h /usr/include 
