ARG MONERO_VERSION="0.18.3.4"

# DOWNLOAD STAGE #######################################################################################
FROM debian:12.8-slim AS download

# Set the Monero version and URLs
ARG MONERO_VERSION
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

# download signing key
RUN wget -qO /tmp/key.key ${MONERO_PGP_KEY}

# verify and import signing key
RUN FINGERPRINT=$(gpg --keyid-format long --show-keys --with-fingerprint /tmp/key.key | tr -s " ") \
    && { echo ${FINGERPRINT} | grep -q "Key fingerprint = ${MONERO_PGP_FINGERPRINT}" \
    && echo ${FINGERPRINT} | grep -q "uid binaryFate <binaryfate@getmonero.org>" \
    && gpg --import /tmp/key.key; } \
    || exit 1

# verify PGP signature of the official hash file list
RUN SIGNATURE=$(wget -qO- ${MONERO_HASH_FILE} | gpg --verify 2>&1 | tr -s " ") \
    && { echo ${SIGNATURE} | grep -q "Primary key fingerprint: ${MONERO_PGP_FINGERPRINT}" \
    && echo ${SIGNATURE} | grep -q 'Good signature from "binaryFate <binaryfate@getmonero.org>"'; } \
    || exit 1

# verify the expected archive hash against official hash file list
RUN wget -qO- ${MONERO_HASH_FILE} | tr -s " " | grep -q "${MONERO_ARCHIVE_HASH} ${MONERO_ARCHIVE_NAME}" || exit 1

# verify the expected archive hash against calculated hash
RUN sha256sum /tmp/${MONERO_ARCHIVE_NAME} | cut -c 1-64 | grep -q ${MONERO_ARCHIVE_HASH} || exit 1

# extract archive contents --> /tmp/monero
RUN mkdir /tmp/monero && tar -xjf /tmp/${MONERO_ARCHIVE_NAME} --strip-components=1 -C /tmp/monero

# clean up
RUN rm /tmp/${MONERO_ARCHIVE_NAME} /tmp/key.key

# FINAL STAGE #######################################################################################
FROM debian:12.8-slim AS final
ARG MONERO_USER="monero"
ARG MONERO_VERSION
ARG PUID
ARG PGID
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN groupadd -g ${PGID} ${MONERO_USER} && useradd -m -s /bin/bash -u ${PUID} -g ${PGID} ${MONERO_USER}
RUN mkdir -p /etc/monero && chown -R ${MONERO_USER}:${MONERO_USER} /etc/monero

# copy and enable entrypoint script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh && sed -i -e "s/VERSION_NUMBER/${MONERO_VERSION}/" /entrypoint.sh

# switch to MONERO_USER
USER "${MONERO_USER}:${MONERO_USER}"

ENTRYPOINT [ "/entrypoint.sh" ]

# copy monerod binary
WORKDIR /home/${MONERO_USER}
COPY --chown=${MONERO_USER}:root --from=download /tmp/monero/monerod /usr/local/bin/monerod

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
