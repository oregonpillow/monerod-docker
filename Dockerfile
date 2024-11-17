# DOWNLOAD STAGE #######################################################################################
FROM debian:12.8-slim AS download

# Set the Monero version and URLs
ARG MONERO_VERSION="0.18.3.4"
ENV MONERO_PGP_FINGERPRINT="81AC 591F E9C4 B65C 5806 AFC3 F0AF 4D46 2A0B DF92"
ENV MONERO_PGP_KEY="https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc"
ENV MONERO_ARCHIVE_HASH="51ba03928d189c1c11b5379cab17dd9ae8d2230056dc05c872d0f8dba4a87f1d"
ENV MONERO_ARCHIVE_NAME="monero-linux-x64-v${MONERO_VERSION}.tar.bz2"
ENV MONERO_ARCHIVE_URL=https://downloads.getmonero.org/cli/${MONERO_ARCHIVE_NAME}
ENV MONERO_HASH_FILE="https://www.getmonero.org/downloads/hashes.txt"

# install dependencies
RUN apt-get update && apt-get install -y wget gnupg2 bzip2 coreutils && rm -rf /var/lib/apt/lists/*

# download archive
RUN wget -P /tmp ${MONERO_ARCHIVE_URL} 

# import lead maintainer PGP Key
RUN wget -qO- ${MONERO_PGP_KEY} | gpg --import

# verify PGP signature of the official hash file list
RUN SIGNATURE=$(wget -qO- ${MONERO_HASH_FILE} | gpg --verify 2>&1) \
    && { echo ${SIGNATURE} | grep -q "Primary key fingerprint: ${MONERO_PGP_FINGERPRINT}" \
    && echo ${SIGNATURE} | grep -q 'Good signature from "binaryFate <binaryfate@getmonero.org>"'; } \
    || exit 1

# verify the expected archive hash against official hash file list
#   WARNING: pay attention to the double space between hash and filename!
RUN wget -qO- ${MONERO_HASH_FILE} | grep -q "$MONERO_ARCHIVE_HASH  $MONERO_ARCHIVE_NAME" || exit 1

# verify the expected archive hash against calculated hash
RUN sha256sum /tmp/${MONERO_ARCHIVE_NAME} | cut -c 1-64 | grep -q ${MONERO_ARCHIVE_HASH} || exit 1

# extract archive contents --> /tmp/monero
RUN mkdir /tmp/monero && tar -xjf /tmp/${MONERO_ARCHIVE_NAME} --strip-components=1 -C /tmp/monero

# Clean up archive
RUN rm /tmp/${MONERO_ARCHIVE_NAME}

# FINAL STAGE #######################################################################################
FROM debian:12.8-slim AS final
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash monero && mkdir -p /home/monero/.bitmonero && chown -R monero:monero /home/monero/.bitmonero
RUN mkdir -p /etc/monero && chown -R monero:monero /etc/monero

# copy and enable entrypoint script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# install and configure fixuid and switch to MONERO_USER
ARG MONERO_USER="monero"
ARG FIXUID_VERSION="0.6.0"
RUN wget https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz \
    -O /tmp/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz -C /usr/local/bin \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid && \
    printf "user: ${MONERO_USER}\ngroup: ${MONERO_USER}\n" >/etc/fixuid/config.yml

# switch to MONERO_USER
USER "${MONERO_USER}:${MONERO_USER}"

# copy monerod binary
WORKDIR /home/${MONERO_USER}
COPY --chown=monero:monero --from=download /tmp/monero/monerod /usr/local/bin/monerod

# p2p port
EXPOSE 18080

# restricted RPC port
EXPOSE 18089

# unrestricted RPC port
EXPOSE 18081

# healthcheck against get_info endpoint
HEALTHCHECK --interval=30s --timeout=5s \
    CMD { wget --quiet --output-document=- http://localhost:18081/get_height | grep --quiet '"status": "OK"'; } \
    || exit 1

CMD ["--config-file=/etc/monero/monerod.conf"]
