#!/bin/bash
#####################################################################
##               MINECRAFT DOCKER PROVISIONING SCRIPT              ##
##               ******** RUN AS A SUPERUSER ********              ##
##                                                                 ##
## Author:                                             Luke Wyatt  ##
## Contact:                                      <luke@meat.space> ##
## Create Date:                                         2016.12.21 ##
## Repository:    github.com/lukeawyatt/provision-docker-minecraft ##
#####################################################################

# REQUIREMENTS:
# ****************
# Linux Host
# Docker >= 17.09

# PRELIMINARY CONFIGURATION
# *************************
#
# This is the name of the host, local to this configuration only.
# Use only ALPHA-NUMERIC characters with no spaces.
HOST=GIBSON
#
# Broadcast Settings, true to use authentication, false to allow anonymous access
# You must use false to allow hacked clients
ONLINE_MODE=false
#
# These are Minecraft server settings. Use the relative naming
# to derive the values and use the presets as a template for the datatypes.
VERSION="1.12.2"
MOTD="[SERVER VER $VERSION] =====||:::::::::::::::::::::::::>"
ICON="https://pbs.twimg.com/profile_images/529297979744600065/0UJnJADo.png"
ANNOUNCE_PLAYER_ACHIEVEMENTS=true
FORCE_GAMEMODE=true
HARDCORE=false
MAX_PLAYERS=10
PVP=true
#
# OPS: Administator players - comma delimited with no space
OPS="Lawbringer"
#
# WHITELIST: Allowed players - comma delimited with no space
# Leave this commented out if you'd like open access for everyone
# WHITELIST="Bob,Jon"
#
# DIFFICULTY Values: peaceful, easy, normal, hard
DIFFICULTY="easy"
#
# GAME MODE Values: creative (1), survival (0), adventure (2), spectator (3)
MODE=0
#
# These are Minecraft specific world settings. Use the relative naming
# to derive the values and use the presets as a template for the datatypes.
LEVEL_NAME="LostIslands"
SEED="-6970159017625830527"
VIEW_DISTANCE=12
MAX_BUILD_HEIGHT=256
GENERATE_STRUCTURES=true
SPAWN_ANIMALS=true
SPAWN_MONSTERS=true
SPAWN_NPC=true
ALLOW_NETHER=true
ENABLE_COMMAND_BLOCK=true
#
# LEVEL TYPE Values: DEFAULT, FLAT, LARGEBIOMES, AMPLIFIED, CUSTOMIZED
LEVEL_TYPE="DEFAULT"
#
# These are JVM options for advanced setup. Uncomment if you need to pass in arguments
# JVM_OPTS="-Xms128M -Xmx512M"
#
# This specifies whether the cleanup process should be ran or not.
# To enable, uncomment the line below. Only use if you understand what you're doing.  
# This pruning process will remove all unused images, networks, volumes, and any stopped containers.
# CLEANUP="set"


# LEAVE EVERYTHING ALONE BELOW THIS LINE
# **************************************
# SYSTEM SETUP
echo "1) SYSTEM SETUP"
systemctl enable docker
echo;


# PULL MINECRAFT DOCKER IMAGES
echo "2) PULLING MINECRAFT SERVER IMAGE"
docker pull itzg/minecraft-server:latest
echo;echo;


# STAGE ENVIRONMENT
echo "3.A) STAGING MINECRAFT CONTAINERS"
echo;
echo "Stopping existing Minecraft Server container if exists..."
docker stop Minecraft
echo "Removing existing Minecraft Server container if exists..."
docker rm Minecraft
echo;

echo "3.B) STAGING ENVIRONMENT"
echo;
echo "Creating folder structure..."

echo "/$HOST/volumes"
mkdir -p "/$HOST/volumes"
echo;

echo "Removing old configuration for rebuild..."
rm -rf "/$HOST/volumes/minecraft/config"
rm -rf "/$HOST/volumes/minecraft/logs"
rm -rf "/$HOST/volumes/minecraft/server.properties"
echo;

echo "3.B) PREPPING CONFIGURATION"
echo;

WHITELISTPARAM=""
if [ -z ${WHITELIST+x} ]; then 
	echo "No whitelist supplied... skipping"
else 
	echo "Whitelist supplied... setting env var"
	WHITELISTPARAM="--env WHITELIST=\"$WHITELIST\""
fi

JVMOPTSPARAM=""
if [ -z ${JVM_OPTS+x} ]; then 
	echo "No JVM options supplied... skipping"
else 
	echo "JVM options supplied... setting env var"
	JVMOPTSPARAM="--env JVM_OPTS=\"$JVM_OPTS\""
fi
echo;echo;


# RUN CONTAINER
echo "4) RUNNING CONTAINER"
docker run \
	--volume /$HOST/volumes/minecraft:/data \
	--env EULA=true \
	--env VERSION="$VERSION" \
	--env DIFFICULTY="$DIFFICULTY" \
	--env MODE="$MODE" \
	--env OPS="$OPS" \
	--env MAX_PLAYERS=$MAX_PLAYERS \
	--env MAX_BUILD_HEIGHT=$MAX_BUILD_HEIGHT \
	--env VIEW_DISTANCE=$VIEW_DISTANCE \
	--env MOTD="$MOTD" \
	--env ICON="$ICON" \
	--env ONLINE_MODE=$ONLINE_MODE \
	--env ANNOUNCE_PLAYER_ACHIEVEMENTS=$ANNOUNCE_PLAYER_ACHIEVEMENTS \
	--env FORCE_GAMEMODE=$FORCE_GAMEMODE \
	--env HARDCORE=$HARDCORE \
	--env PVP=$PVP \
	--env ALLOW_NETHER=$ALLOW_NETHER \
	--env GENERATE_STRUCTURES=$GENERATE_STRUCTURES \
	--env SPAWN_ANIMALS=$SPAWN_ANIMALS \
	--env SPAWN_MONSTERS=$SPAWN_MONSTERS \
	--env SPAWN_NPC=$SPAWN_NPC \
	--env ENABLE_COMMAND_BLOCK=$ENABLE_COMMAND_BLOCK \
	--env SEED="$SEED" \
	--env LEVEL_TYPE="$LEVEL_TYPE" \
	--env LEVEL="$LEVEL_NAME" \
	--env UNUSED="PLACEHOLDER" $WHITELISTPARAM $JVMOPTSPARAM \
	--publish=25565:25565 \
	--detach=true \
	--restart=unless-stopped \
	--tty \
	--name=Minecraft \
	itzg/minecraft-server:latest
echo;echo;


# DOCKER CLEANUP
if [ -z ${CLEANUP+x} ]; then 
	echo "5) BYPASSING CLEANUP PROCESS"
	echo;echo;
else 
	echo "5) DOCKER CLEANUP TIME"
	echo "Removing empty containers..."
	docker system prune -a -f --volumes
	# FOR USE WITH DOCKER ENGINE <= 1.13
	# echo "NOTE THIS WILL ERROR WHEN NOTHING NEEDS TO BE CLEANED UP"
	# docker rm -v $(docker ps -a -q -f status=exited)
	# echo "Removing unused images..."
	# echo "NOTE THIS WILL ERROR WHEN NOTHING NEEDS TO BE CLEANED UP"
	# docker rmi $(docker images -f "dangling=true" -q)
	echo;echo;
fi
