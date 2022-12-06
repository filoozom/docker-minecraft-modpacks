# Docker Minecraft Modpacks

## Volumes

- /server

## Environment variables

| Name              | Required   | Default            | Description                                         |
| ----------------- | ---------- | ------------------ | --------------------------------------------------- |
| `MODPACK_ID`      | `true`     | ID of the modpack  | ID of the modpack, found on FTB or CurseForge       |
| `MODPACK_VERSION` | `false` \* | latest             | Version of the modpack                              |
| `EULA`            | `true`     | `false`            | Accept Minecraft's EULA                             |
| `MOTD`            | `false`    | -                  | Message Of The Day (`server.properties`)            |
| `LEVEL`           | `false`    | -                  | Level (`server.properties`)                         |
| `LEVEL_TYPE`      | `false`    | -                  | Level type (`server.properties`)                    |
| `OPS`             | `false`    | -                  | Operators (`ops.txt`)                               |
| `USER_UID`        | `false`    | `567`              | Linux user id of the running user (`minecraft`)     |
| `USER_GID`        | `false`    | `567`              | Linux group id of the running user (`minecraft`)    |
| `MIN_RAM`         | `false`    | depends on modpack | Minimum amount of RAM allocated to the JVM (`-Xms`) |
| `MAX_RAM`         | `false`    | depends on modpack | Maximum amount of RAM allocated to the JVM (`-Xmx`) |
| `JAVA_ARGS`       | `false`    | -                  | General Java arguments (advanced)                   |

\* but highly recommended so it doesn't automatically update on restart

# Security

This container runs Java as a non-privileged user, with `uid=567` and `gid=567` by default (see `USER_UID` and `USER_GID` environment variables), meaning that local volumes need to set permissions accordingly.

## Example command

```
# Create volumes and set permissions
mkdir data
chown -R 567:567 data

# Run the server
docker run -d \
  --name stoneblock3 \
  --restart unless-stopped \
  -p 25565:25565 \
  -e MODPACK_ID=100 \
  -e EULA=true \
  -v $(pwd)/data:/server \
  filoozom/minecraft-modpacks
```
