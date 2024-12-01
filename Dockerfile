ARG MONERO_VERSION

# DOWNLOAD STAGE #######################################################################################
FROM debian:12.8-slim AS download

# Set the Monero version and URLs
ARG MONERO_VERSION
ENV MONERO_PGP_FINGERPRINT="81AC 591F E9C4 B65C 5806 AFC3 F0AF 4D46 2A0B DF92"
ENV MONERO_PGP_KEY="https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc"
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

# verify the calculated archive hash against official hash file list
RUN CALCULATED_HASH=$(sha256sum /tmp/${MONERO_ARCHIVE_NAME} | cut -c 1-64) \
    && { wget -qO- ${MONERO_HASH_FILE} | tr -s " " | grep -q "${CALCULATED_HASH} ${MONERO_ARCHIVE_NAME}"; } \
    || exit 1

# extract archive contents --> /tmp/monero
RUN mkdir /tmp/monero && tar -xjf /tmp/${MONERO_ARCHIVE_NAME} --strip-components=1 -C /tmp/monero

# clean up
RUN rm /tmp/${MONERO_ARCHIVE_NAME} /tmp/key.key

# FINAL STAGE #######################################################################################
# FROM debian:12.8-slim AS final
FROM docker-baseimage-debian AS final
#ARG MONERO_USER="monero"
ARG MONERO_VERSION
# ARG PUID
# ARG PGID
# RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/* && \
#     groupadd -g ${PGID} ${MONERO_USER} && useradd -m -s /bin/bash -u ${PUID} -g ${PGID} ${MONERO_USER} && \
#     mkdir -p /etc/monero && chown -R ${MONERO_USER}:${MONERO_USER} /etc/monero

RUN mkdir -p /etc/monero && mkdir -p /app/monero/bitmonero && mkdir /app/monero/bin

# copy and enable entrypoint script
# ADD entrypoint.sh /app/monero/entrypoint.sh
# RUN chmod +x /app/monero/entrypoint.sh && sed -i -e "s/VERSION_NUMBER/${MONERO_VERSION}/" /app/monero/entrypoint.sh

# switch to MONERO_USER
# USER "${MONERO_USER}:${MONERO_USER}"

# ENTRYPOINT [ "/entrypoint.sh" ]

# copy monerod binary
# WORKDIR /home/${MONERO_USER}
COPY --from=download /tmp/monero/monerod /app/monero/bin/monerod

COPY root/ /

# p2p port
EXPOSE 18080

# restricted RPC port
EXPOSE 18089

# unrestricted RPC port
EXPOSE 18081

# healthcheck against get_info endpoint
# HEALTHCHECK --interval=30s --timeout=5s \
#     CMD { wget --quiet --output-document=- http://localhost:18081/get_height | grep --quiet '"status": "OK"'; } \
#     || exit 1

# CMD ["--config-file=/etc/monero/monerod.conf"]
