#!/bin/bash
#####################################################################
##              DOCKER MINECRAFT PROVISIONING SCRIPT               ##
##              ******** RUN AS A SUPERUSER ********               ##
##                      - BEDROCK EDITION -                        ##
##                                                                 ##
## Author:                                             Luke Wyatt  ##
## Contact:                                         <luke@skre.ws> ##
## Create | Modify Dates:                  2016.12.21 | 2022.04.23 ##
## Repository:    github.com/lukeawyatt/provision-docker-minecraft ##
## Reference:              github.com/itzg/docker-minecraft-server ##
#####################################################################

# BEDROCK USAGE GUIDE:
# ------------
# Copy config.bedrock-example.json and fill in your server configuration.
# From the containing directory, run the following:
#     ./docker.minecraft.bedrock.sh ./your-new-file.json
# That's it! run `docker ps` to check on the health status.

# [HELP] JSON REFERENCE AND ENUMS:
# --------------------------------
# OnlineMode        : True to use MC authentication, False for anonymous access
# Ops               : Administator players - comma delimited with no space
# Whitelist         : Allowed players - comma delimited with no space
# PlayerIdleTimeout : In minutes
# Difficulty        : [ENUM] peaceful, easy, normal, hard
# Gamemode          : [ENUM, INT] creative (1), survival (0), adventure (2)
# LevelType         : [ENUM] DEFAULT, FLAT, LEGACY



########################
# REGION: DECLARATIONS #
########################

JSON=""

function jsonval {
	temp=`echo $JSON | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="*" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/\"//g' | grep -w $PROP | cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
	echo ${temp##*|}
}

function jsonval_property {
	temp=`echo $JSON | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="*" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/\"//g' | grep -w $PROP`
	echo ${temp##*|}
}



######################
# REGION: SANITATION #
######################

if [ -z "$1" ]; then
	echo "No configuration path supplied."
	echo "Exiting..."
	exit
fi

echo "Configuration Path: $1"
if [ -f $1 ]; then
    JSON=$(<$1)
	echo "Dumping JSON Configuration:"
	echo "$JSON"
	echo
fi

if [ -z "$JSON" ]; then
	echo "No configuration found."
	echo "Exiting..."
	exit
fi



###################
# REGION: PARSING #
###################

PROP='VersionTag'
VERSION_TAG=`jsonval`
echo "Parsing value for ContainerName: $VERSION_TAG"

PROP='ContainerName'
CONTAINER_NAME=`jsonval`
echo "Parsing value for ContainerName: $CONTAINER_NAME"

PROP='CleanupAfterProvision'
CLEANUP=`jsonval`
echo "Parsing value for CleanupAfterProvision: $CLEANUP"

PROP='VolumePath'
VOLUME_PATH=`jsonval_property`
VOLUME_PATH=$(echo "$VOLUME_PATH" | grep -oP "^VolumePath: \K.*")
echo "Parsing value for VolumePath: $VOLUME_PATH"

PROP='ServerName'
SERVER_NAME=`jsonval`
echo "Parsing value for ServerName: $SERVER_NAME"

PROP='ServerPort'
SERVER_PORT=`jsonval`
echo "Parsing value for ServerPort: $SERVER_PORT"

PROP='MinecraftVersion'
VERSION=`jsonval`
echo "Parsing value for MinecraftVersion: $VERSION"

PROP='OnlineMode'
ONLINE_MODE=`jsonval`
echo "Parsing value for OnlineMode: $ONLINE_MODE"

PROP='Gamemode'
MODE=`jsonval`
echo "Parsing value for Gamemode: $MODE"

PROP='Difficulty'
DIFFICULTY=`jsonval`
echo "Parsing value for Difficulty: $DIFFICULTY"

PROP='MaxPlayers'
MAX_PLAYERS=`jsonval`
echo "Parsing value for MaxPlayers: $MAX_PLAYERS"

PROP='ViewDistance'
VIEW_DISTANCE=`jsonval`
echo "Parsing value for ViewDistance: $VIEW_DISTANCE"

PROP='PlayerIdleTimeout'
PLAYER_IDLE_TIMEOUT=`jsonval`
echo "Parsing value for PlayerIdleTimeout: $PLAYER_IDLE_TIMEOUT"

PROP='LevelName'
LEVEL_NAME=`jsonval`
echo "Parsing value for LevelName: $LEVEL_NAME"

PROP='LevelType'
LEVEL_TYPE=`jsonval`
echo "Parsing value for LevelType: $LEVEL_TYPE"

PROP='Seed'
SEED=`jsonval`
echo "Parsing value for Seed: $SEED"

PROP='Ops'
OPS=`jsonval`
echo "Parsing value for Ops: $OPS"

PROP='Whitelist'
WHITELIST=`jsonval`
echo "Parsing value for Whitelist: $WHITELIST"

PROP='AllowCheats'
ALLOW_CHEATS=`jsonval`
echo "Parsing value for AllowCheats: $ALLOW_CHEATS"

PROP='TexturePackRequired'
TEXTUREPACK_REQUIRED=`jsonval`
echo "Parsing value for TexturePackRequired: $TEXTUREPACK_REQUIRED"



########################
# REGION: PROVISIONING #
########################

echo "Pulling Minecraft server image..."
docker pull itzg/minecraft-bedrock-server:$VERSION_TAG
echo "Done."
echo;echo;

echo "(Re)Staging Minecraft container(s)..."
echo "Stopping existing Minecraft Server container (if exists)..."
docker stop $CONTAINER_NAME
echo "Removing existing Minecraft Server container (if exists)..."
docker rm $CONTAINER_NAME
echo "Done."
echo;echo;

echo "(Re)Staging Environment..."
echo "Creating folder structure..."
echo "$VOLUME_PATH"
mkdir -p "$VOLUME_PATH"
echo "Removing old configuration for rebuild..."
rm -rf "$VOLUME_PATH/server.properties"
echo "Done."
echo;echo;

echo "Preparing configuration..."
WHITELISTPARAM=''
if [ -z ${WHITELIST} ]; then 
	echo "No whitelist supplied... skipping"
else 
	echo "Whitelist supplied... setting env var"
	WHITELISTPARAM="--env WHITELIST=\"$WHITELIST\""
fi
echo "Done."
echo;echo;

echo "Executing container..."
docker run \
	--volume $VOLUME_PATH:/data \
	--env EULA=TRUE \
	--env SERVER_NAME="$SERVER_NAME" \
	--env VERSION="$VERSION" \
	--env ONLINE_MODE=$ONLINE_MODE \
	--env GAMEMODE="$MODE" \
	--env DIFFICULTY="$DIFFICULTY" \
	--env MAX_PLAYERS=$MAX_PLAYERS \
	--env VIEW_DISTANCE=$VIEW_DISTANCE \
	--env PLAYER_IDLE_TIMEOUT=$PLAYER_IDLE_TIMEOUT \
	--env LEVEL_NAME="$LEVEL_NAME" \
	--env LEVEL_TYPE="$LEVEL_TYPE" \
	--env LEVEL_SEED="$SEED" \
	--env OPS="$OPS" \
	--env TEXTUREPACK_REQUIRED=$TEXTUREPACK_REQUIRED \
	--env ALLOW_CHEATS=$ALLOW_CHEATS $WHITELISTPARAM \
	--publish=$SERVER_PORT:19132/udp \
	--detach=true \
	--restart=unless-stopped \
	--tty \
	--name=$CONTAINER_NAME \
	itzg/minecraft-bedrock-server:$VERSION_TAG
echo "Done."
echo;echo;

echo "Cleaning up..."
if [ "${CLEANUP,,}" == "true" ]; then 
	echo "Removing empty containers..."
	docker system prune -a -f --volumes
else
	echo "Bypassing cleanup process..."
fi
echo "All finished!"
echo;echo;
