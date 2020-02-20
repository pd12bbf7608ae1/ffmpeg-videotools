#!/bin/bash
infodir="$HOME/Documents"

filename=$(basename $1)
infoname=$(date +%Y%m%d-%H%M%S)-$filename.nfo

info=$(mediainfo $1)
duration=$(mediainfo --Inform="Video;%Duration/String3%" $1)
# info=$(cat $1)


vedio_begin=$(echo "$info" | grep -n "^Video" | sed -n '1 p' | cut -d ':' -f 1)
vedio_length=$(echo "$info" | sed "1,$vedio_begin d" | grep -n "^$" | sed -n '1 p' | cut -d ':' -f 1)
test -z $vedio_length && vedio_length=$(($(echo "$info" | grep -n ".*" | sed -n -e '$ p' | cut -d ':' -f 1) - $vedio_begin))

# echo $vedio_begin
# echo $vedio_length

audio_number=$(echo "$info" | grep -c "^Audio")
# echo "audio_begin"
if [ "$audio_number" -ge "1" ]; then
	for ((i = 1; i <= ${audio_number}; i=i+1))
	do
		audio_begin[$i]=$(echo "$info" | grep -n "^Audio" | sed -n "$i p" | cut -d ':' -f 1)
		audio_length[$i]=$(echo "$info" | sed "1,${audio_begin[$i]} d" | grep -n "^$" | sed -n '1 p' | cut -d ":" -f 1)
		test -z ${audio_length[$i]} && audio_length[$i]=$(($(echo "$info" | grep -n ".*" | sed -n -e '$ p' | cut -d ':' -f 1) - ${audio_begin[$i]}))
		# echo ${audio_begin[$i]}
		# echo ${audio_length[$i]}
		# echo "-------------"
		# exit 0
	done
	else
	audio_begin[1]=1
	audio_length[1]=1
fi


text_number=$(echo "$info" | grep -c "^Text")
# echo "text_begin"
if [ "$text_number" -ge "1" ]; then
	for ((i = 1; i <= ${text_number}; i=i+1))
	do
		text_begin[$i]=$(echo "$info" | grep -n "^Text" | sed -n "$i p" | cut -d ':' -f 1)
		text_length[$i]=$(echo "$info" | sed "1,${text_begin[$i]} d" | grep -n "^$" | sed -n '1 p' | cut -d ":" -f 1)
		test -z ${text_length[$i]} && text_length[$i]=$(($(echo "$info" | grep -n ".*" | sed -n -e '$ p' | cut -d ':' -f 1) - ${text_begin[$i]}))
	done
	else
	text_begin[1]=1
	text_length[1]=1
fi

menu_begin=$(echo "$info" | grep -n "^Menu" | sed -n "1 p" | cut -d ':' -f 1)
# echo menu_begin
# echo $menu_begin

general_info=$(echo "$info" | sed -n "1,$((${vedio_begin}-1)) p")
video_info=$(echo "$info" | sed -n "$vedio_begin,$(($vedio_begin+$vedio_length)) p")
# echo "$video_info"

# echo "$general_info"

	echo "★★★★★ General Information ★★★★★"
	echo "File Name............: $(basename $(echo "$general_info" | grep "^Complete name  " | cut -d ':' -f 2))"
	echo "File Size............: $(echo "$general_info" | grep "^File size  " | cut -d ':' -f 2| sed "s/ //g")"
	echo "Duration.............: $duration (HH:MM:SS.MMM)"
	echo "Video Bit Rate.......: $(echo "$video_info" | grep "^Bit rate  " | cut -d ':' -f 2 | sed "s/ //g")"
	echo "Video Codec..........: $(echo "$video_info" | grep "^Format  " | cut -d ':' -f 2 | sed "s/ //g"),$(echo "$video_info" | grep "^Format profile" | cut -d ':' -f 2 | sed "s/ //g")"
	echo "Frame Rate...........: $(echo "$video_info" | grep "^Frame rate  " | cut -d ':' -f 2 | sed "s/ //g" | sed "s/(.*)//g")"
	echo "Resolution...........: $(echo "$video_info" | grep "^Width  " | cut -d ':' -f 2 | sed -e "s/ //g" -e "s/pixels//g")x$(echo "$video_info" | grep "^Height  " | cut -d ':' -f 2 | sed -e "s/ //g" -e "s/pixels//g")"
	
if [ "$audio_number" -eq "1" ]; then
	audio_info=$(echo "$info" | sed -n "${audio_begin[1]},$((${audio_begin[1]}+${audio_length[1]})) p")
	
	echo "Audio................: [$(echo "$audio_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$audio_info" | grep "^Title  " | cut -d ":" -f 2 | sed "s/^ //g") $(echo "$audio_info" | grep "^Bit rate  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Channel(s)  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Format  " | cut -d ":" -f 2 | sed "s/^ //g")"
fi

if [ "$audio_number" -gt "1" ]; then
	for ((i = 1; i <= ${audio_number}; i=i+1))
	do
		audio_info=$(echo "$info" | sed -n "${audio_begin[$i]},$((${audio_begin[$i]}+${audio_length[$i]})) p")
		printf "Audio#%02d" $i
		echo ".............: [$(echo "$audio_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$audio_info" | grep "^Title  " | cut -d ":" -f 2 | sed "s/^ //g") $(echo "$audio_info" | grep "^Bit rate  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Channel(s)  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Format  " | cut -d ":" -f 2 | sed "s/^ //g")"
	done
fi

if [ "$text_number" -eq "1" ]; then
	text_info=$(echo "$info" | sed -n "${text_begin[1]},$((${text_begin[1]}+${text_length[1]})) p")
	echo "Subtitle.............: [$(echo "$text_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$text_info" | grep "^Title   " | cut -d ':' -f 2 | sed "s/ //g") $(echo "$text_info" | grep "^Codec ID  " | cut -d ':' -f 2 | sed "s/ //g")"
fi

if [ "$text_number" -gt "1" ]; then
	for ((i = 1; i <= ${text_number}; i=i+1))
	do
		text_info=$(echo "$info" | sed -n "${text_begin[$i]},$((${text_begin[$i]}+${text_length[$i]})) p")
		printf "Subtitle#%02d" $i
		echo "..........: [$(echo "$text_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$text_info" | grep "^Title   " | cut -d ':' -f 2 | sed "s/ //g") $(echo "$text_info" | grep "^Codec ID  " | cut -d ':' -f 2 | sed "s/ //g")"
	done
fi
