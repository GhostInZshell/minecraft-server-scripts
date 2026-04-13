#! /bin/bash

set -euo pipefail

# Colors
YLW="\e[33m"
GRN="\e[32m"
RED="\e[31m"
CYN="\e[36m"
BLD="\e[1m"
RESET="\e[0m"


echo
paper_ver=$(ps aux | grep [j]ava | grep -Eo 'paper.*jar' || true)
echo "Paper Version: ${paper_ver:-unknown}"
echo
printf "%-24s %-14s %-14s %-12s\n" "Plugin" "Local" "Latest" "Status"
echo "==================================================================="

#ls -1 ~/paper_minecraft/plugins/*.jar | rev | cut -d'/' -f1 | rev | sed -E 's/(.+)-([0-9][0-9.].*)\.jar/\1\t\2/' | column -s $'\t' -t

# func to get latest version from hangar
get_latest_ver_hangar() {
	local author="$1"
	local project="$2"
	curl -fsSL -X GET "https://hangar.papermc.io/api/v1/projects/${author}/${project}/latestrelease" \
	-H 'accept: text/plain' 2>/dev/null || true
}

# for jar in ~/paper_minecraft/plugins/*.jar; do
# 	base=$(basename $jar .jar)
# 	name=$(echo "$base" | sed -E 's/(.+)-([0-9][0-9.].*)/\1/')
# 	ver=$(echo "$base" | sed -E 's/(.+)-([0-9][0-9.].*)/\2/')
# 	#echo $name $ver

shopt -s nullglob nocasematch
for jar in ~/paper_minecraft/plugins/*.jar; do
	base=$(basename "$jar" .jar)

	# Extract name and version from filename like Name-1.2.3.jar
	name=$(sed -E 's/(.+)-([0-9].*)/\1/' <<<"$base")
	ver=$(sed -E 's/(.+)-([0-9].*)/\2/' <<<"$base")
	core_ver="${ver%%-*}"   # 5.13-paper -> 5.13

	latest=""

	case "$name" in
		Chunky-Bukkit)
			latest=$(get_latest_ver_hangar "pop4959" "Chunky")
			;;
		DamageIndicator)
			latest=$(get_latest_ver_hangar "Magiccheese1" "DamageIndicator")
			;;
		EssentialsX*)
			latest=$(get_latest_ver_hangar "EssentialsX" "Essentials")
			;;
		bluemap)
			latest=$(get_latest_ver_hangar "Blue" "BlueMap")
			;;
		goodnight)
			latest=$(get_latest_ver_hangar "Jelly-Pudding" "Goodnight")
			;;
		ViaVersion)
			latest=$(get_latest_ver_hangar "ViaVersion" "ViaVersion")
			;;
		ViaBackward)
			latest=$(get_latest_ver_hanger "ViaVersion" "ViaBackwards")
			;;
		 *)
			latest=""
			;;
	esac


	status="n/a"
	if [[ -n "$latest" ]]; then
	  if [[ "$ver" == "$latest" || "${ver#v}" == "${latest#v}" || "${core_ver#v}" == "${latest#v}" ]]; then
	    status="${GRN}up-to-date${RESET}"
	  else
	    status="${RED}update${RESET}"
	  fi
	fi

	# Print using the original case for name
	printf "%-24s %-14s %-14s %-12b\n" "$name" "$ver" "${latest:-?}" "$status"
done
shopt -u nocasematch
