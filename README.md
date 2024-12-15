# monerod-docker

## About

Monero daemon in a docker container:

- ✅ Built using official Monero binary
- ✅ Binary verified against official PGP signature
- ✅ Binary verified against official sha256 sum
- ✅ Container runs as non-root user with single process
- ✅ Multi-platform support --> [Docker Hub](https://registry.hub.docker.com/r/oregonpillow/monerod)

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

## Getting Started

By default, the images maintained at [Docker Hub](https://registry.hub.docker.com/r/oregonpillow/monerod) are built using
a non-root user with PUID/GUID of 1000:1000 respectively. If you want to change this to another id, [build the image locally](#building-image-locally) and update the PUID/GUID arguments.

### Using multi-platform images on DockerHub

```bash
# IMPORTANT: folder must exist before starting container
mkdir data

# pull + start container
docker compose up -d
```

### Building image locally

Update the build arguments in `docker-compose.build.yml`. See [Build Arguments](#build-arguments) for more information.

When setting PUID/GUID arguments, you can run `id -u` and `id -g` locally, to find your current user/group respectively.

```bash
# IMPORTANT: folder must exist before starting container
mkdir data

# build + start container
docker compose -f docker-compose.build.yml up -d
```

## Build Arguments

| Argument         | Description                                                                                                                                                                   |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MONERO_VERSION` | The version of Monero to use. e.g. `0.18.3.4`                                                                                                                                 |
| `PUID`           | User ID for the Monero user. e.g. `1000`                                                                                                                                      |
| `PGID`           | Group ID for the Monero user. e.g. `1000`                                                                                                                                     |
| `PLATFORM`       | Platform binary to download. Possible values: `android-armv7`, `android-armv8`, `freebsd-x64`, `linux-armv7`, `linux-armv8`, `linux-x64`, `linux-x86`, `mac-armv8`, `mac-x64` |

## Building monerod binary from source

This project is focused on simplicity, security and easy maintainability. For this reason it builds images only with pre-built official binaries.
If you want the Monero dameon built from source in a container, I recommend:

- [sethforprivacy/simple-monerod-docker](https://github.com/sethforprivacy/simple-monerod-docker)
- [official Monero Dockerfile](https://github.com/monero-project/monero)
