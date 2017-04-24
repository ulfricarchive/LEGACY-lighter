#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
mcver=$(cat "$workdir/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
paperjar="../../Lighter-Server/target/lighter-$mcver.jar"
vanillajar="../$mcver/$mcver.jar"

(
    cd "$workdir/Paperclip"
    mvn clean package "-Dmcver=$mcver" "-Dpaperjar=$paperjar" "-Dvanillajar=$vanillajar"
)
cp "$workdir/Paperclip/target/paperclip-${mcver}.jar" "$basedir/paperclip.jar"

echo ""
echo ""
echo ""
echo "Build success!"
echo "Copied final jar to $(cd "$basedir" && pwd -P)/paperclip.jar"
)
