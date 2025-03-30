```
           ++++++++++++
        ++++++++++++++++++
       ++++++++++++++++++++
      +++  ++++++++++++ ++++
     ++++   ++++++++++  +++++    ###    ###   ########  ###    ##  ####### ########   #######
     ++++     ++++++    +++++    ####  ####  ##     ### #####  ##  ##      ###   ##  ##     ###
     ++++       ++      +++++    #### #####  ##      ## ###### ##  ####### ######## ###      ##
     ++++   ###    ###  +++++   ### #### ### ##     ### ### #####  ##      ###  ##   ##     ###
            ##########          ##  ###   ##  ########  ###   ###  ####### ###   ##   ########
       ####################
        ##################                   monerod: The Monero Daemon
           ############
                ##
```

## About

**Source Code**: https://github.com/oregonpillow/monerod

Monero daemon in a docker container:

- ✅ Built using official Monero binary
- ✅ Binary verified against official PGP signature
- ✅ Binary verified against official sha256 sum
- ✅ Container runs as non-root user with single process
- ✅ multi-platform support

## Getting Started

- Create a directory `data` before starting container
- The container runs as non-root user using PUID/GUID of 1000:1000 respectively
- See https://docs.getmonero.org/interacting/monerod-reference/ for example config

```yml
services:
  monerod:
    image: oregonpillow/monerod:latest
    container_name: monerod
    restart: unless-stopped
    volumes:
      - ./data:/app/monero/bitmonero
      - ./monerod.conf:/app/monero/monerod.conf
    ports:
      - 18081:18081 # rpc
      - 18089:18089 # restricted rpc
      - 18080:18080 # p2p
```
