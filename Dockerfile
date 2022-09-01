# syntax=docker/dockerfile:1
# Create a Bolivarcoin/Bolicoin Docker image
# FOR BOLIVARCOIN CORE v2.0.0.2 https://github.com/BOLI-Project/BolivarCoin/releases/tag/v2.0.0.2
# 
# VERSION 0.9.1
# AUTHOR "Asdrúbal Velásquez Lagrave @Visionario" 
# L.L.A.P. - Live long and prosper
# 
# 
# 
# STEPS TO USE (BUILD, PREPARE and RUN)
# 
# BUILD image using defaults:
#       docker build . --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t bolicoin-core-alpine:v2.0.0.2
#       NOTE: Why UID and GID is important?, please read https://stackoverflow.com/questions/44683119/dockerfile-replicate-the-host-user-uid-and-gid-to-the-image
#
#
# PREPARE for first time run: 
#       1) Create and go to a new boli directory. Very important use mkdir with your host user account
#          Ex. mkdir -p /PATH_TO_BOLI_DATA/bolidata
#
#       2) Open, edit at your convenience Generic_Bolivarcoin.conf
#          NOTE: You MUST set rpcuser and rpcpassword or use commands below to automatically set
#          sed -i "s/rpcuser=CHANGE_THIS/rpcuser=$(openssl rand -hex 16)/g" Generic_Bolivarcoin.conf
#          sed -i "s/rpcpassword=CHANGE_THIS/rpcpassword=$(openssl rand -hex 16)/g" Generic_Bolivarcoin.conf
#
#       3) Copy Generic_Bolivarcoin.conf to /PATH_TO_BOLI_DATA/bolidata/Bolivarcoin.conf
#          cp Generic_Bolivarcoin.conf ./bolidata/Bolivarcoin.conf
#
#
# RUN container:
#       docker run -dit --rm --name boli -p 3893:3893 -v $(pwd)/bolidata:"/bolidata" bolicoin-core-alpine:v2.0.0.2
#
#
# Entering container (user 'boli')
#       docker exec -it boli /bin/sh
#
# Executing commands (user 'boli')
#       docker exec boli bolivarcoin-cli getinfo
#
# Entering container using root credentials
#       docker exec -it -u 0 boli /bin/sh
#
#
###############################################################################

# Build stage for BerkeleyDB
# ┏━┓╺┳╸┏━┓┏━╸┏━╸    ┏┓ ┏━╸┏━┓╻┏ ┏━╸╻  ┏━╸╻ ╻╺┳┓┏┓ 
# ┗━┓ ┃ ┣━┫┃╺┓┣╸ ╹   ┣┻┓┣╸ ┣┳┛┣┻┓┣╸ ┃  ┣╸ ┗┳┛ ┃┃┣┻┓
# ┗━┛ ╹ ╹ ╹┗━┛┗━╸╹   ┗━┛┗━╸╹┗╸╹ ╹┗━╸┗━╸┗━╸ ╹ ╺┻┛┗━┛
FROM alpine:3.9 as berkeleydb

RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add libressl

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j4
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs





# Build stage for Bolicoin v2.0.0.2 (Compile)
# ┏━┓╺┳╸┏━┓┏━╸┏━╸    ┏┓ ╻ ╻╻╻  ╺┳┓
# ┗━┓ ┃ ┣━┫┃╺┓┣╸ ╹   ┣┻┓┃ ┃┃┃   ┃┃
# ┗━┛ ╹ ╹ ╹┗━┛┗━╸╹   ┗━┛┗━┛╹┗━╸╺┻┛
FROM alpine:3.9 as boli-build

LABEL maintainer="Asdrúbal Velásquez Lagrave @Visionario" 

COPY --from=berkeleydb /opt /opt

RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add boost-dev
RUN apk --no-cache add build-base
RUN apk --no-cache add chrpath
RUN apk --no-cache add file
RUN apk --no-cache add gnupg
RUN apk --no-cache add libevent-dev
RUN apk --no-cache add libressl
RUN apk --no-cache add libressl-dev
RUN apk --no-cache add libsodium-dev
RUN apk --no-cache add libtool
RUN apk --no-cache add linux-headers
RUN apk --no-cache add protobuf-dev
RUN apk --no-cache add zeromq-dev
RUN apk --no-cache add git

WORKDIR /tmp

# Clone Bolicoin/BolivarCoin official repository and compile
#RUN wget https://github.com/BOLI-Project/BolivarCoin/archive/refs/tags/v2.0.0.2.tar.gz \
RUN git clone https://github.com/BOLI-Project/BolivarCoin.git \
    && cd /tmp/BolivarCoin \
    && echo -e "\n----------> EXECUTING AUTOGEN" \
    && ./autogen.sh \
    && echo -e "\n----------> EXECUTING CONFIGURE" \
    && ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon \
    && echo -e "\n----------> EXECUTING MAKE" \
    && make -j$(nproc) 


# Prepare binaries bolivarcoind, bolivarcoin-cli and bolivarcoin-tx for the next stage
RUN cd /tmp/BolivarCoin/src \
    && mkdir /tmp/bolibins/ \
    && strip bolivarcoind && mv bolivarcoind /tmp/bolibins/ \
    && strip bolivarcoin-cli && mv bolivarcoin-cli /tmp/bolibins/ \
    && strip bolivarcoin-tx && mv bolivarcoin-tx /tmp/bolibins/



#
# Build stage for Bolicoin v2.0.0.2 distrib
# ┏━┓╺┳╸┏━┓┏━╸┏━╸    ╺┳┓╻┏━┓╺┳╸┏━┓╻┏┓ ╻ ╻╺┳╸╻┏━┓┏┓╻
# ┗━┓ ┃ ┣━┫┃╺┓┣╸ ╹    ┃┃┃┗━┓ ┃ ┣┳┛┃┣┻┓┃ ┃ ┃ ┃┃ ┃┃┗┫
# ┗━┛ ╹ ╹ ╹┗━┛┗━╸╹   ╺┻┛╹┗━┛ ╹ ╹┗╸╹┗━┛┗━┛ ╹ ╹┗━┛╹ ╹
FROM alpine:3.9 as bolicoin
LABEL maintainer="Asdrúbal Velásquez Lagrave @Visionario" 
LABEL version="0.9.1"

# Environments
ENV PS1='[\u@\h \W]\$ '
ENV BOLI_DATA "/bolidata"
ENV USERNAME="boli"
ENV GROUPNAME=$USERNAME
ENV PORT=3893

# ARGuments
ARG BOLI_HOME="/opt/boli"
ARG UID=1000
ARG GID=1000

RUN apk --no-cache add \
    boost \
    boost-program_options \
    libressl \
    zeromq \
    libevent \
    protobuf \
    tini

COPY --from=boli-build /tmp/bolibins/* /usr/bin/

# Create system user and group
RUN addgroup -g $GID $GROUPNAME \
    && adduser -u $UID -D -G $GROUPNAME -h $BOLI_HOME -g "Bolicoin/Bolivarcoin Node" $USERNAME 

COPY daemon_boli_start.sh /opt/boli/daemon_boli_start.sh
RUN chmod +x /opt/boli/daemon_boli_start.sh

RUN mkdir "$BOLI_DATA" \
    && chown -R $USERNAME:$GROUPNAME "$BOLI_DATA" \
    && ln -sfn "$BOLI_DATA" "$BOLI_HOME/.Bolivarcoin" \
    && chown -h $USERNAME:$GROUPNAME "$BOLI_HOME/.Bolivarcoin"

WORKDIR $BOLI_DATA

VOLUME ["$BOLI_DATA"]

USER $USERNAME

EXPOSE $PORT

# Alpine distro require ENTRYPOINT ["/bin/sh"] for detached mode
# Read about tini (https://github.com/krallin/tini)
ENTRYPOINT ["/sbin/tini", "--", "/bin/sh"]

# Daemon must starts with "-daemon=0" for detached mode
CMD ["/opt/boli/daemon_boli_start.sh","-daemon=0"]

