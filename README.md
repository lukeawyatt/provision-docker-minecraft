# Docker Minecraft Provisioning Script

This script is intended to provision a quick Minecraft Server solution based on Docker container technology.

## Usage

Pull down the script and example configuration

```shell
# FOR JAVA
wget https://raw.githubusercontent.com/lukeawyatt/provision-docker-minecraft/master/java/docker.minecraft.java.sh -O docker.minecraft.java.sh
wget https://raw.githubusercontent.com/lukeawyatt/provision-docker-minecraft/master/java/config.java-example.json -O config.java-example.json

# FOR BEDROCK
wget https://raw.githubusercontent.com/lukeawyatt/provision-docker-minecraft/master/bedrock/docker.minecraft.bedrock.sh -O docker.minecraft.bedrock.sh
wget https://raw.githubusercontent.com/lukeawyatt/provision-docker-minecraft/master/bedrock/config.bedrock-example.json -O config.bedrock-example.json
```

Modify the permissions to allow execution

```shell
# FOR JAVA
chmod u+x docker.minecraft.java.sh

# FOR BEDROCK
chmod u+x docker.minecraft.bedrock.sh
```

Edit the script to change our configuration

```shell
# FOR JAVA
vim config.java-example.json

# FOR BEDROCK
vim config.bedrock-example.json
```

Execute the script with superuser privileges to provision the Minecraft Server.  Clip the output for your records.  This script can be re-ran since it'll break down the existing containers first.  This script can also be re-ran as is to upgrade the base docker images.

```shell
# FOR JAVA
sudo ./docker.minecraft.java.sh ./config.java-example.json

# FOR BEDROCK
sudo ./docker.minecraft.bedrock.sh ./config.bedrock-example.json
```

## Configuration

Edit the PRELIMINARY CONFIGURATION section of the script to your desired setting.

#### CONTAINER SETTINGS

These settings affect the docker container and the underlying JVM.

```shell
# FOR JAVA
"ContainerName": "AwesomeServer"
"VolumePath": "\VOLUMES\AwesomeServer"
"ServerName": "AwesomeServer"
"ServerPort": 25565
"Memory": "2G"

# FOR BEDROCK
"ContainerName": "AwesomeServer"
"VolumePath": "\VOLUMES\AwesomeServer"
"ServerName": "AwesomeServer"
"ServerPort": 19132
```

#### BROADCAST SETTINGS

If set to true, this server will use Minecraft Authentication.  Set this to false if you'd like to run an anonymous server.

```shell
# FOR BOTH JAVA AND BEDROCK
"OnlineMode": true
```

#### SERVER TYPES

For Java servers only, the server type engine can be modified to enhance the server capabilities.  Available values are: SPIGOT BUKKIT PAPER TUINITY PURPUR YATOPIA MAGMA MOHIST CATSERVER FTB FTBA CURSEFORGE SPONGEVANILLA FABRIC. Additional configuration might be required.

```shell
# FOR JAVA
"ServerType": "BUKKIT"
```

#### SERVER SETTINGS

These are Minecraft server settings. Use the relative naming to derive the values and use the presets as a template for the datatypes.

```shell
# FOR JAVA
"MinecraftVersion": "1.16.5"
"IconUrl": "URL_TO_ICON"
"OverrideIconOnRerun": true
"EnableAutopause": true
"AutopauseTimeout": 3600
"AnnouncePlayerAchievements": true
"ForceGamemode": true
"Hardcore": false
"MaxPlayers": 20
"ViewDistance": 10
"PlayerIdleTimeout": 15
"AllowPvp": true
"AllowFlight": true

# FOR BEDROCK
"MinecraftVersion": "LATEST"
"MaxPlayers": 20
"ViewDistance": 10
"PlayerIdleTimeout": 10
"AllowCheats": true
```

#### MOTD AND ENCODING

For Java servers only, the broadcast MOTD can be set and customized to show additional server data in the Multiplayer List.  

```shell
# FOR JAVA
"MOTD": "YOUR_SERVER_BROADCAST_MESSAGE"

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

# EXAMPLE
"MOTD": "\u00A76Line 1\n\u00A7bLine2"
```

#### ADMINISTRATORS

This adds administative players. Values are comma delimited with no space. The Bedrock version utilizes the user's XUID instead. There are sites available to handle lookups or alternatively, you can get this value from the logs after a user joins.

```shell
# FOR JAVA
"Ops": "ElderlyBull69"

# FOR BEDROCK
"Ops": "2535463267832599"
```

#### WHITELISTED PLAYERS

This adds any allowed players. Values are comma delimited with no space. Leave this commented out if you'd like open access for everyone. The Bedrock version utilizes the user's XUID instead

```shell
# FOR JAVA
"Whitelist": "Bob,Jon"

# FOR BEDROCK
"Whitelist": "2535463267832599,5535462267832469"
```

#### DIFFICULTY

This sets the game difficulty. Available values are: peaceful, easy, normal, hard.

```shell
# FOR BOTH JAVA AND BEDROCK
"Difficulty": "normal"
```

#### GAME MODE

This sets the game mode. Available values can be set by either the ID or name.

```shell
# FOR JAVA, AVAILABLE VALUES: creative (1), survival (0), adventure (2), spectator (3)
"Gamemode": "survival"

# FOR BEDROCK, AVAILABLE VALUES: creative (1), survival (0), adventure (2)
"Gamemode": "survival"
```

#### WORLD SETTINGS

These are Minecraft specific world settings. Use the relative naming to derive the values and use the presets as a template for the datatypes.

```shell
# FOR JAVA
"LevelName": "DefaultWorld"
"Seed": "-6970159017625830527"
"SpawnProtection": 0
"MaxBuildHeight": 256
"AllowNether": true
"AllowCommandBlock": true
"GenerateStructures": true
"SpawnAnimals": true
"SpawnMonsters": true
"SpawnNpcs": true

# FOR BEDROCK
"LevelName": "DefaultWorld"
"Seed": "2151901553968352745"
"TexturePackRequired": true
```

#### LEVEL TYPE, GENERATORS, AND DOWNLOADING WORLDS

This sets the world generation type. Available values are: 

```shell
# FOR JAVA, AVAILABLE VALUES: DEFAULT, FLAT, LARGEBIOMES, AMPLIFIED, CUSTOMIZED (USE GeneratorSettings)
"LevelType": "DEFAULT"
"GeneratorSettings": ""

# OR FOR A PRESET WORLD
"WorldDownloadUrl": ""

# FOR BEDROCK, AVAILABLE VALUES: DEFAULT, FLAT, LEGACY
"LevelType": "DEFAULT"
```

#### CLEANUP

This specifies whether the cleanup process should be ran or not. To enable, set to true.  Only use if you understand what you're doing.  This pruning process will remove all unused images, networks, volumes, and any stopped containers.

```shell
# FOR BOTH JAVA AND BEDROCK
"CleanupAfterProvision": true
```

## Upgrading

When new versions of the packaged Dockerhub images are released, simply re-run this script to upgrade.  The new image will be downloaded and utilized during re-build.  For Minecraft related server versions, increment the VERSION variable in the script and re-run to change the active version.

## Feedback

If you have any problems with or questions about this script, please contact me using [GitHub Issues](https://github.com/lukeawyatt/provision-docker-minecraft/issues)
