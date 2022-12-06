FROM alpine

# General config
WORKDIR /server
EXPOSE 25565

# Add entrypoint
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh

