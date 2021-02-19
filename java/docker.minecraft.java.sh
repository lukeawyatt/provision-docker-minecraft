#!/bin/bash
#####################################################################
##              DOCKER MINECRAFT PROVISIONING SCRIPT               ##
##              ******** RUN AS A SUPERUSER ********               ##
##                       -- JAVA EDITION --                        ##
##                                                                 ##
## Author:                                             Luke Wyatt  ##
## Contact:                                         <luke@skre.ws> ##
## Create | Modify Dates:                  2016.12.21 | 2021.02.18 ##
## Repository:    github.com/lukeawyatt/provision-docker-minecraft ##
## Reference:              github.com/itzg/docker-minecraft-server ##
#####################################################################

# JAVA USAGE GUIDE:
# ------------
# Copy config.java-example.json and fill in your server configuration.
# From the containing directory, run the following:
#     ./docker.minecraft.java.sh ./your-new-file.json
# That's it! run `docker ps` to check on the health status.

# [HELP] JSON REFERENCE AND ENUMS:
# --------------------------------
# OnlineMode        : True to use MC authentication, False for anonymous access
# Ops               : Administator players - comma delimited with no space
# Whitelist         : Allowed players - comma delimited with no space
# AutopauseTimeout  : In seconds
# Memory            : This is for the JAVA HEAP, not the container limit
# PlayerIdleTimeout : In minutes
# Difficulty        : [ENUM] peaceful, easy, normal, hard
# Gamemode          : [ENUM, INT] creative (1), survival (0), adventure (2), spectator (3)
# LevelType         : [ENUM] DEFAULT, FLAT, LARGEBIOMES, AMPLIFIED, CUSTOMIZED
# ServerType        : [ENUM] SPIGOT BUKKIT PAPER TUINITY PURPUR YATOPIA MAGMA MOHIST CATSERVER FTB FTBA CURSEFORGE SPONGEVANILLA FABRIC

# MESSAGE OF THE DAY ENCODING:
# -----------------------------
# \u00A70 : Black
# \u00A71 : Dark Blue
# \u00A72 : Dark Green
# \u00A73 : Dark Cyan
# \u00A74 : Dark Red
# \u00A75 : Purple
# \u00A76 : Orange
# \u00A77 : Light Grey
# \u00A78 : Dark Grey
# \u00A79 : Lilac
# \u00A7a : Light Green
# \u00A7b : Light Cyan
# \u00A7c : Light Red
# \u00A7d : Pink
# \u00A7e : Yellow
# \u00A7f : White
# \u00A7l : Bold
# \u00A7o : Italicized
# \u00A7n : Underlined
# \u00A7m : Strikethrough
# \u00A7k : "Glitch" effect
# \n      : New Line



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

PROP='ServerType'
TYPE=`jsonval`
echo "Parsing value for ServerType: $TYPE"

PROP='MinecraftVersion'
VERSION=`jsonval`
echo "Parsing value for MinecraftVersion: $VERSION"

PROP='IconUrl'
ICON=`jsonval_property`
ICON=$(echo "$ICON" | grep -oP "^IconUrl: \K.*")
echo "Parsing value for IconUrl: $ICON"

PROP='OverrideIconOnRerun'
OVERRIDE_ICON=`jsonval`
echo "Parsing value for OverrideIconOnRerun: $OVERRIDE_ICON"

PROP='MOTD'
MOTD=`jsonval_property`
MOTD=$(echo "$MOTD" | grep -oP "^MOTD: \K.*")
echo "Parsing value for MOTD: $MOTD"

PROP='AnnouncePlayerAchievements'
ANNOUNCE_PLAYER_ACHIEVEMENTS=`jsonval`
echo "Parsing value for AnnouncePlayerAchievements: $ANNOUNCE_PLAYER_ACHIEVEMENTS"

PROP='OnlineMode'
ONLINE_MODE=`jsonval`
echo "Parsing value for OnlineMode: $ONLINE_MODE"

PROP='EnableAutopause'
ENABLE_AUTOPAUSE=`jsonval`
echo "Parsing value for EnableAutopause: $ENABLE_AUTOPAUSE"

PROP='AutopauseTimeout'
AUTOPAUSE_TIMEOUT_EST=`jsonval`
echo "Parsing value for AutopauseTimeout: $AUTOPAUSE_TIMEOUT_EST"

PROP='Memory'
MEMORY=`jsonval`
echo "Parsing value for Memory: $MEMORY"

PROP='Gamemode'
MODE=`jsonval`
echo "Parsing value for Gamemode: $MODE"

PROP='ForceGamemode'
FORCE_GAMEMODE=`jsonval`
echo "Parsing value for ForceGamemode: $FORCE_GAMEMODE"

PROP='Difficulty'
DIFFICULTY=`jsonval`
echo "Parsing value for Difficulty: $DIFFICULTY"

PROP='Hardcore'
HARDCORE=`jsonval`
echo "Parsing value for Hardcore: $HARDCORE"

PROP='MaxPlayers'
MAX_PLAYERS=`jsonval`
echo "Parsing value for MaxPlayers: $MAX_PLAYERS"

PROP='MaxBuildHeight'
MAX_BUILD_HEIGHT=`jsonval`
echo "Parsing value for MaxBuildHeight: $MAX_BUILD_HEIGHT"

PROP='ViewDistance'
VIEW_DISTANCE=`jsonval`
echo "Parsing value for ViewDistance: $VIEW_DISTANCE"

PROP='SpawnProtection'
SPAWN_PROTECTION=`jsonval`
echo "Parsing value for SpawnProtection: $SPAWN_PROTECTION"

PROP='PlayerIdleTimeout'
PLAYER_IDLE_TIMEOUT=`jsonval`
echo "Parsing value for PlayerIdleTimeout: $PLAYER_IDLE_TIMEOUT"

PROP='LevelName'
LEVEL=`jsonval`
echo "Parsing value for LevelName: $LEVEL"

PROP='LevelType'
LEVEL_TYPE=`jsonval`
echo "Parsing value for LevelType: $LEVEL_TYPE"

PROP='Seed'
SEED=`jsonval`
echo "Parsing value for Seed: $SEED"

PROP='GeneratorSettings'
GENERATOR_SETTINGS=`jsonval`
echo "Parsing value for GeneratorSettings: $GENERATOR_SETTINGS"

PROP='WorldDownloadUrl'
WORLD=`jsonval_property`
WORLD=$(echo "$WORLD" | grep -oP "^WorldDownloadUrl: \K.*")
echo "Parsing value for WorldDownloadUrl: $WORLD"

PROP='Ops'
OPS=`jsonval`
echo "Parsing value for Ops: $OPS"

PROP='Whitelist'
WHITELIST=`jsonval`
echo "Parsing value for Whitelist: $WHITELIST"

PROP='AllowPvp'
PVP=`jsonval`
echo "Parsing value for AllowPvp: $PVP"

PROP='AllowCommandBlock'
ENABLE_COMMAND_BLOCK=`jsonval`
echo "Parsing value for AllowCommandBlock: $ENABLE_COMMAND_BLOCK"

PROP='AllowNether'
ALLOW_NETHER=`jsonval`
echo "Parsing value for AllowNether: $ALLOW_NETHER"

PROP='AllowFlight'
ALLOW_FLIGHT=`jsonval`
echo "Parsing value for AllowFlight: $ALLOW_FLIGHT"

PROP='GenerateStructures'
GENERATE_STRUCTURES=`jsonval`
echo "Parsing value for GenerateStructures: $GENERATE_STRUCTURES"

PROP='SpawnAnimals'
SPAWN_ANIMALS=`jsonval`
echo "Parsing value for SpawnAnimals: $SPAWN_ANIMALS"

PROP='SpawnMonsters'
SPAWN_MONSTERS=`jsonval`
echo "Parsing value for SpawnMonsters: $SPAWN_MONSTERS"

PROP='SpawnNpcs'
SPAWN_NPCS=`jsonval`
echo "Parsing value for SpawnNpcs: $SPAWN_NPCS"
echo;echo;



###################
# REGION: PARSING #
###################

echo "Pulling Minecraft server image..."
docker pull itzg/minecraft-server:latest
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
rm -rf "$VOLUME_PATH/config"
rm -rf "$VOLUME_PATH/server.properties"
echo "Refreshing old logs..."
rm -rf "$VOLUME_PATH/logs"
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

GENERATORSETTINGSPARAM=''
if [ -z ${GENERATOR_SETTINGS} ]; then 
	echo "No generator settings supplied... skipping"
else 
	echo "Generator settings supplied... setting env var"
	GENERATORSETTINGSPARAM="--env GENERATOR_SETTINGS=\"$GENERATOR_SETTINGS\""
fi

WORLDDOWNLOADPARAM=''
if [ -z ${WORLD} ]; then 
	echo "No world download url supplied... skipping"
else 
	echo "World download URL supplied... setting env var"
	WORLDDOWNLOADPARAM="--env WORLD=\"$WORLD\""
fi
echo "Done."
echo;echo;

echo "Executing container..."
docker run \
	--volume $VOLUME_PATH:/data \
	--env EULA=true \
	--env SERVER_NAME="$SERVER_NAME" \
	--env TYPE="$TYPE" \
	--env VERSION="$VERSION" \
	--env ICON="$ICON" \
	--env OVERRIDE_ICON=$OVERRIDE_ICON \
	--env MOTD="$MOTD" \
	--env ANNOUNCE_PLAYER_ACHIEVEMENTS=$ANNOUNCE_PLAYER_ACHIEVEMENTS \
	--env ONLINE_MODE=$ONLINE_MODE \
	--env ENABLE_AUTOPAUSE=$ENABLE_AUTOPAUSE \
	--env AUTOPAUSE_TIMEOUT_EST=$AUTOPAUSE_TIMEOUT_EST \
	--env MEMORY="$MEMORY" \
	--env MODE="$MODE" \
	--env FORCE_GAMEMODE=$FORCE_GAMEMODE \
	--env DIFFICULTY="$DIFFICULTY" \
	--env HARDCORE=$HARDCORE \
	--env MAX_PLAYERS=$MAX_PLAYERS \
	--env MAX_BUILD_HEIGHT=$MAX_BUILD_HEIGHT \
	--env VIEW_DISTANCE=$VIEW_DISTANCE \
	--env SPAWN_PROTECTION=$SPAWN_PROTECTION \
	--env PLAYER_IDLE_TIMEOUT=$PLAYER_IDLE_TIMEOUT \
	--env LEVEL="$LEVEL" \
	--env LEVEL_TYPE="$LEVEL_TYPE" \
	--env SEED="$SEED" \
	--env OPS="$OPS" \
	--env PVP=$PVP \
	--env ENABLE_COMMAND_BLOCK=$ENABLE_COMMAND_BLOCK \
	--env ALLOW_NETHER=$ALLOW_NETHER \
	--env ALLOW_FLIGHT=$ALLOW_FLIGHT \
	--env GENERATE_STRUCTURES=$GENERATE_STRUCTURES \
	--env SPAWN_ANIMALS=$SPAWN_ANIMALS \
	--env SPAWN_MONSTERS=$SPAWN_MONSTERS \
	--env SPAWN_NPCS=$SPAWN_NPC \
	--env SNOOPER_ENABLED=false $WHITELISTPARAM $GENERATORSETTINGSPARAM $WORLDDOWNLOADPARAM \
	--publish=$SERVER_PORT:25565 \
	--detach=true \
	--restart=unless-stopped \
	--tty \
	--name=$CONTAINER_NAME \
	itzg/minecraft-server:latest
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
