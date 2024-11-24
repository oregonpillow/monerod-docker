# monerod-docker

## About

A monero docker build based on the official pre-built binary. Binary is verified against official PGP Signatures and hash checks.

- If you want to build from scratch, I recommend:
  - [sethforprivacy/simple-monerod-docker](https://github.com/sethforprivacy/simple-monerod-docker)
  - [official Monero Dockerfile](https://github.com/monero-project/monero)

```
$ docker logs monerod

           ++++++++++++
        ++++++++++++++++++
       ++++++++++++++++++++
      +++  ++++++++++++ ++++
     ++++   ++++++++++  +++++    ###    ###   ########  ###    ##  ####### ########   #######
     ++++     ++++++    +++++    ####  ####  ##     ### #####  ##  ##      ###   ##  ##     ###
     ++++   #   ++   #  +++++    #### #####  ##      ## ###### ##  ####### ######## ###      ##
     ++++   ###    ###  +++++   ### #### ### ##     ### ### #####  ##      ###  ##   ##     ###
            ##########          ##  ###   ##  ########  ###   ###  ####### ###   ##   ########
       ####################
        ##################                   monerod: The Monero Daemon
           ############                      version: v0.18.3.4
                ##

2024-11-17 18:26:36.035 I Monero 'Fluorine Fermi' (v0.18.3.4-release)
2024-11-17 18:26:36.035 I Initializing cryptonote protocol...
2024-11-17 18:26:36.035 I Cryptonote protocol initialized OK
2024-11-17 18:26:36.036 I Initializing core...
2024-11-17 18:26:36.036 I Loading blockchain from folder /home/monero/.bitmonero/lmdb ...
2024-11-17 18:26:36.151 I Loading checkpoints
2024-11-17 18:26:36.152 I Core initialized OK
2024-11-17 18:26:36.152 I Initializing p2p server...
2024-11-17 18:26:36.155 I p2p server initialized OK
2024-11-17 18:26:36.155 I Initializing core RPC server...
2024-11-17 18:26:36.155 I Binding on 0.0.0.0 (IPv4):18081
2024-11-17 18:26:36.155 I core RPC server initialized OK on port: 18081
2024-11-17 18:26:36.156 I Starting core RPC server...
2024-11-17 18:26:36.156 I core RPC server started ok
2024-11-17 18:26:36.156 I Starting p2p net loop...
2024-11-17 18:26:37.156 I
2024-11-17 18:26:37.156 I **********************************************************************
2024-11-17 18:26:37.156 I The daemon will start synchronizing with the network. This may take a long time to complete.
2024-11-17 18:26:37.156 I
2024-11-17 18:26:37.156 I You can set the level of process detailization through "set_log <level|categories>" command,
2024-11-17 18:26:37.156 I where <level> is between 0 (no details) and 4 (very verbose), or custom category based levels (eg, *:WARNING).
2024-11-17 18:26:37.156 I
2024-11-17 18:26:37.156 I Use the "help" command to see the list of available commands.
2024-11-17 18:26:37.156 I Use "help <command>" to see a command's documentation.
2024-11-17 18:26:37.156 I **********************************************************************
2024-11-17 18:26:37.857 I SYNCHRONIZATION started
2024-11-17 18:26:38.712 I Synced 3283512/3283512
2024-11-17 18:26:38.712 I
2024-11-17 18:26:38.712 I **********************************************************************
2024-11-17 18:26:38.712 I You are now synchronized with the network. You may now start monero-wallet-cli.
2024-11-17 18:26:38.712 I
2024-11-17 18:26:38.712 I Use the "help" command to see the list of available commands.
2024-11-17 18:26:38.712 I **********************************************************************
2024-11-17 18:26:43.037 I SYNCHRONIZATION started
2024-11-17 18:26:43.208 I Synced 3283513/3283513
```

## Requirements

- Docker
- docker compose

## Getting Started

- Update the `docker-compose.yml` volume mounts for

  - monero data
  - monero conf file

- Update your desired settings in `monerod.conf`

```bash
mkdir data && sudo chown ${USER}:root data
docker compose up -d
```

## References

- Credit to Seth For Privacy/@sethforprivacy for [simple-monerod-docker](https://github.com/sethforprivacy/simple-monerod-docker), from which several parts were copied or adapted for this project.
