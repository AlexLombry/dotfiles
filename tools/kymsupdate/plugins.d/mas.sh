#!/usr/bin/env bash

# Mac Appstore plugin for KYMSU
# https://github.com/welcoMattic/kymsu

# No distract mode (no user interaction)
[[ $@ =~ "-nodistract" || $@ =~ "-n" ]] && no_distract=true || no_distract=false

testing=1

italic="\033[3m"
underline="\033[4m"
ita_under="\033[3;4m"
bold="\033[1m"
bold_under="\033[1;4m"
redbox="\033[1;41m"
redbold="\033[1;31m"
red="\033[31m"
yellow="\033[33m"
reset="\033[0m"


echo -e "${bold}🍏  Mac App Store updates come fast as lightning ${reset}"

echo ""
echo -e "mas : https://github.com/mas-cli/mas"

command -v mas >/dev/null 2>&1 || { echo -e "\n${bold}mas${reset} is not installed.\n\nRun ${italic}'brew install mas'${reset} for install." && exit 1; }

latest_v=$(curl -s https://api.github.com/repos/mas-cli/mas/releases/latest | jq -j '.tag_name')
current_v=$(mas version)


echo -e "Current version: $current_v"
echo -e "Latest version: $latest_v"

# On teste si mas est installé
if hash mas 2>/dev/null; then

	massy=$(mas outdated)
	echo ""
	#echo "$massy"
	
	nomoreatstore=$(echo "$massy" | grep "not found in store")
	outdated=$(echo "$massy" | grep -v "not found in store")

	if [ -n "$outdated" ]; then
		echo -e "${underline}Availables updates:${reset}"
		echo "$outdated" | awk '{ $1=""; print}'
		echo "--"
		#echo "$outdated" | awk '{ $1=""; $3=""; print}'
		
		echo ""
	
		#if [ "$no_distract" = false ]
		if [[ $testing -ne 1 ]]; then
			a=$(echo -e "Do you wanna run \033[1mmas upgrade${reset} ? (y/n) ")
			read -p "$a" choice
			
			if [ "$choice" == "y" ] || [ "$choice" == "Y" ] || [ "$choice" == "a" ] || [ "$choice" == "A" ]; then		

				while IFS=\n read -r line
				do
					echo "$line"
					idendifiant=$(echo "$line" | awk '{print $1}')
					nom=$(echo "$line" | awk -F "(" '{print $1}' | awk '{ $1=""; print}' | xargs)
					nom_version=$(echo "$line" | awk '{ $1=""; print}')
					version=$(echo "$line" | awk -F "(" '{print $2}' | sed 's/.$//')
					
					echo "$idendifiant - $nom - $version"
					echo "-- fin --"
					
				done <<< "$outdated"

			else
				echo -e "OK, let's continue..."
			fi
		fi
	
	else
		echo -e "${italic}No availables mas updates.${reset}"
	fi
	
	if [ -n "$nomoreatstore" ]; then
		echo -e "\n${underline}Apps no more in App Store:${reset}"
		
		while IFS= read -r line
		do
			id=$(echo "$line" | awk '{print $3}')
			name=$(echo "$line" | awk -F "identify" '{print $2}' | sed 's/.$//' | xargs)
			echo -e "$name ($id)"

		done <<< "$nomoreatstore"

	fi
	
else
	echo -e "Please install mas: ${italic}brew install mas${reset}"
fi

echo ""
echo ""
