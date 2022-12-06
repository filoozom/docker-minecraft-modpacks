#!/bin/ash

set -e

if [ -z "$MODPACK_ID" ]
then
	echo "You must set the MODPACK_ID environment variable"
	exit 2
fi

# Install the modpack if it's a different version
# The installer: https://github.com/CreeperHost/modpacksch-serverdownloader
MODPACK_STRING="$MODPACK_ID-$MODPACK_VERSION"
INSTALLER_URL="https://api.modpacks.ch/public/modpack/$MODPACK_ID/$MODPACK_VERSION/server/linux"

if [ "$MODPACK_STRING" != "$(cat /server/modpack 2>/dev/null)" ]
then
	wget -O /installer $INSTALLER_URL
	chmod +x /installer
	/installer $MODPACK_ID $MODPACK_VERSION --auto

	echo "#!/bin/ash" > run.sh
	grep java ./start.sh >> run.sh
	sed -i 's/"\(jre.*\)"/\/server\/\1/g' run.sh
	chmod +x run.sh

	echo $MODPACK_STRING > /server/modpack
	rm /installer
fi

# Accept eula through environment variable
if ! [[ "$EULA" = "false" ]] || grep -i true eula.txt
then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA by in the container settings."
	exit 3
fi

# Create the server properties file on first boot
if [ ! -f server.properties ]
then
	touch server.properties
fi

# General server config
if [[ -n "$MOTD" ]]
then
	sed -i "/motd\s*=/ c motd=$MOTD" server.properties
fi

if [[ -n "$LEVEL" ]]
then
	sed -i "/level-name\s*=/ c level-name=$LEVEL" server.properties
fi

if [[ -n "$LEVELTYPE" ]]
then
	sed -i "/level-type\s*=/ c level-type=$LEVELTYPE" server.properties
fi

# Operators
if [[ -n "$OPS" ]]
then
	echo $OPS | awk -v RS=, '{print}' >> ops.txt
fi

# Custom Java arguments
echo "$JVM_ARGS" > user_jvm_args.txt

# Min and max ram
if [[ -n "$MIN_RAM" ]]
then
	sed -i "s/-Xms[^ ]*/-Xms${MIN_RAM}/g" ./run.sh
fi

if [[ -n "$MAX_RAM" ]]
then
	sed -i "s/-Xmx[^ ]*/-Xmx${MAX_RAM}/g" ./run.sh
fi

# Create the unprivileged user and change permissions
addgroup -S -g ${USER_GID:-567} minecraft
adduser -h /server -G minecraft -s /bin/ash -S -D -H -u ${USER_UID:-567} minecraft
chown -R minecraft:minecraft /server

# Run server with dropped privileges
su - minecraft ./run.sh

