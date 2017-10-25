# Docker Minecraft Provisioning Script

This script is intended to provision a quick Minecraft Server solution based on container technology.


#### Requirements

* Ubuntu Server 16.04 LTS
* Docker >= 17.09


## Usage

Pull down the script 

```shell
wget https://raw.githubusercontent.com/lukeawyatt/provision-docker-minecraft/master/deploy-docker-minecraft.sh -O deploy-docker-minecraft.sh
```

Modify the permissions to allow execution

```shell
chmod u+x deploy-docker-minecraft.sh
```

Edit the script to change our configuration

```shell
vim deploy-docker-minecraft.sh
```

Execute the script with superuser privileges to provision the Minecraft Server.  Clip the output for your records.  This script can be re-ran since it'll break down the existing containers first.  This script can also be re-ran as is to upgrade the base docker images.
```shell
sudo ./deploy-docker-minecraft.sh
```


## Configuration

Edit the PRELIMINARY CONFIGURATION section of the script to your desired setting.

#### HOST
This is the name of your host, local to this configuration only.  This is used for a volume root. Use only ALPHA-NUMERIC characters with no spaces.

```shell
HOST=GIBSON
```

#### BROADCAST SETTINGS
If set to true, this server will use Minecraft Authentication.  Set this to false if you'd like to run a hacked server.

```shell
ONLINE_MODE=false
```

#### SERVER SETTINGS
These are Minecraft server settings. Use the relative naming to derive the values and use the presets as a template for the datatypes.

```shell
VERSION="1.12.2"
MOTD="[SERVER VER $VERSION] =====||:::::::::::::::::::::::::>"
ICON="https://pbs.twimg.com/profile_images/529297979744600065/0UJnJADo.png"
ANNOUNCE_PLAYER_ACHIEVEMENTS=true
FORCE_GAMEMODE=true
HARDCORE=false
MAX_PLAYERS=10
PVP=true
```

#### ADMINISTRATORS
This adds administative players. Values are comma delimited with no space.

```shell
OPS="Lawbringer"
```

#### WHITELISTED PLAYERS
This adds any allowed players. Values are comma delimited with no space. Leave this commented out if you'd like open access for everyone.

```shell
WHITELIST="Bob,Jon"
```

#### DIFFICULTY
This sets the game difficulty. Available values are: peaceful, easy, normal, hard

```shell
DIFFICULTY="easy"
```

#### GAME MODE
This sets the game mode. Available values (either ID or name) are: creative (1), survival (0), adventure (2), spectator (3)

```shell
MODE=0
```

#### WORLD SETTINGS
These are Minecraft specific world settings. Use the relative naming to derive the values and use the presets as a template for the datatypes.

```shell
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
```

#### LEVEL TYPE
This sets the world generation type. Available values are: DEFAULT, FLAT, LARGEBIOMES, AMPLIFIED, CUSTOMIZED

```shell
LEVEL_TYPE="DEFAULT"
```

#### JVM OPTIONS
These are JVM options for advanced setup. Uncomment if you need to pass in arguments such as memory heap allocation.

```shell
# JVM_OPTS="-Xms128M -Xmx512M"
```

#### CLEANUP
This specifies whether the cleanup process should be ran or not. To enable, uncomment the line below.  Only use if you understand what you're doing.  This pruning process will remove all unused images, networks, volumes, and any stopped containers.

```shell
CLEANUP="set"
```


## Upgrading

When new versions of the packaged Dockerhub images are released, simply re-run this script to upgrade.  The new image will be downloaded and utilized during re-build.  For Minecraft related server versions, increment the VERSION variable in the script and re-run to change the active version.


## Tested Versions

My test environment is as follows.  If you have tested in another environment/version set, please add to this list.

* Ubuntu 16.04.3 LTS
* GNU Bash 4.3.48
* Docker CE 17.09.0


## Feedback

If you have any problems with or questions about this script, please contact me using a [GitHub Issue](https://github.com/lukeawyatt/provision-docker-minecraft/issues)
