#!/bin/bash

#常数设置

picturepath=$HOME/Pictures/VedioCapture
#截图保存位置

logpath=$HOME/Pictures/VedioCapture
#视频信息和截图上传信息保存位置

randomshift_flag=1
#自动选取时间时是否加入随机值

logofile=
#logo设置，留空为不使用logo

gap=10
#视频缩略图中的间隙 单位像素

comment=
#缩略图中的Comment字段

#缩略图顶端说明文字设置
font="Courier"
#字体

fontsize=24
#大小

fontcolor=Black
#颜色

font_shadowcolor=Black
#阴影颜色

font_shadowx=1
#阴影x偏移 单位像素

font_shadowy=1
#阴影y偏移 单位像素
#缩略图顶端说明文字设置结束

#缩略图时间戳设置
require_timestamp=1
# 缩略图中是否需要时间戳，非1或者不存在为不生成

timestamp_fontcolor=White
timestamp_shadowcolor=Black
timestamp_font="$font"
timestamp_fontsize="$fontsize"
timestamp_shadowx=1
timestamp_shadowy=1
#同说明文字设置

timestamp_x=0.5
timestamp_y=0.99
#时间戳位于图片位置的比例,如0.5为中央

backgroundcolor=White
#缩略图背景颜色

token=
#token留空使用匿名上传，如需加入自己的账号到 https://sm.ms/home/apitoken 生成token填入
#常数设置结束
printhelp(){
echo "A shell script using mediainfo, ffmpeg and curl to generate vedio information, thumbnail and upload to sm.ms image host.

Usage:
bash <script file path> <video file path> [options...]
Or
bash <script file path> [options...] <video file path> (Not recommend, might fail on some systems.)

Options:
 -h	print help messages
 -j	convert png to jpg(default is png format)
 -m <transverse number>x<longitudinal number>
	generate multiple screenshots to an image with the given tiles(eg. 4x4)
 -M [time]
	generate single screenshot at the given time(format [HH:]MM:SS[.m...])
 -n [number]
	generate multiple screenshots with the given number
 -s	do not show and save video information
 -u	upload images to sm.ms, default is png format, upload jpg format with -j option
 -w [number]
	set the width(in pixel) of screenshots in -M, -n options, default is the width of video
 -W [number]
	set the width(in pixel) of each screenshots in -m options, default is the width of video
	eg. options: -W 1000 -m 4x4 you will get a image with about 4000 pixels width, contain 16 screenshots
	
Examples:
bash <script file path> <video file path>
	show video information and save to txt file
	
bash <script file path> <video file path> -M 00:10:10 -sjuW 1280
	do not show and save video information, generate single screenshot at 00:10:10 with 1280 pixels width, convert screenshot to jpg format and upload it to sm.ms

bash <script file path> <video file path> -m 4x4 -suw 500
	do not show and save video information, generate 16 screenshots to an image, 500 pixels width for each screenshot, upload it to sm.ms

bash <script file path> <video file path> -n 3 -m 3x3 -ujw 500
	show video information and save to txt file, generate 3 screenshots with the same resolution of the video, generate 9 screenshots to an image, 500 pixels width for each screenshot, convert outputs to jpg format and upload to sm.ms"

}

#输入检测
if [ $# -eq "0" ]; then
	printhelp
	exit 0
fi

if [ -e "$1" ]; then
	filepath=$1
	shift
	else
	if [ -e "${!#}" ]; then
		filepath=${!#}
		else
		echo "You must specify a media file."
		printhelp
		exit 1
	fi
fi

while getopts "sjuhm:M:n:w:W:" opt
do
    case $opt in
		s)
		slience_flag=1
        ;;
        j)
		jpg_flag=1
        ;;
        m)
		if [ -z $OPTARG ]; then
			echo "No parameter found for mosaic(-m)!"
			echo "Type -h for help."
			exit 1
		else
			mosaic_x=$(echo $OPTARG | cut -d "x" -f 1)
			mosaic_y=$(echo $OPTARG | cut -d "x" -f 2)
			expr $mosaic_x + 0 > /dev/null 2>&1
			if [ $? -ne "0" ]; then
				echo "mosaic(-m) usage error"
				echo "Type -h for help."
				exit 1
			fi
			expr $mosaic_y + 0 > /dev/null 2>&1
			if [ $? -ne "0" ]; then
				echo "mosaic(-m) usage error"
				echo "Type -h for help."
				exit 1
			fi
		fi
        ;;
		u)
		upload_img_flag=1
		;;
		M)
		manual_time=$OPTARG
		if [ -z $manual_time ]; then
			echo "manual usage error"
			echo "Type -h for help."
			exit 1
		fi
		;;
		n)
		number=$OPTARG
		expr $number + 0 > /dev/null 2>&1
		if [ $? -ne "0" ] || [ $number -le "0" ]; then
			echo "number(-n) usage error"
			echo "Type -h for help."
			exit 1
		fi
		;;
		h)
		printhelp
		exit 0
		;;
		w)
		mosaic_width=$OPTARG
		expr $mosaic_width + 0 > /dev/null 2>&1
		if [ $? -ne "0" ] || [ $mosaic_width -le "0" ]; then
			echo "mosaic_width(-w) usage error"
			echo "Type -h for help."
			exit 1
		fi
		;;
		W)
		separate_width=$OPTARG
		expr $separate_width + 0 > /dev/null 2>&1
		if [ $? -ne "0" ] || [ $separate_width -le "0" ]; then
			echo "separate_width(-W) usage error"
			echo "Type -h for help."
			exit 1
		fi
		;;
        ?)
        echo "unknow parameter"
		echo "Type -h for help."
		exit 1
        ;;
    esac
done

#输入检测完成

# filepath
# jpg_flag
# slience_flag
# mosaic_x
# mosaic_y
# upload_img_flag
# manual_time
# number
# mosaic_width
# separate_width

test -e "$picturepath" || mkdir "$picturepath"
test -e "$logpath" || mkdir "$logpath"

filename=$(basename $filepath)
info=$(mediainfo $filepath)
duration=$(mediainfo --Inform="Video;%Duration/String3%" $filepath)

vedio_begin=$(echo "$info" | grep -n "^Video" | sed -n '1 p' | cut -d ':' -f 1)
vedio_length=$(echo "$info" | sed "1,$vedio_begin d" | grep -n "^$" | sed -n '1 p' | cut -d ':' -f 1)
test -z $vedio_length && vedio_length=$(($(echo "$info" | grep -n ".*" | sed -n -e '$ p' | cut -d ':' -f 1) - $vedio_begin))
audio_number=$(echo "$info" | grep -c "^Audio")
if [ "$audio_number" -ge "1" ]; then
	for ((i = 1; i <= ${audio_number}; i=i+1))
	do
		audio_begin[$i]=$(echo "$info" | grep -n "^Audio" | sed -n "$i p" | cut -d ':' -f 1)
		audio_length[$i]=$(echo "$info" | sed "1,${audio_begin[$i]} d" | grep -n "^$" | sed -n '1 p' | cut -d ":" -f 1)
		test -z ${audio_length[$i]} && audio_length[$i]=$(($(echo "$info" | grep -n ".*" | sed -n -e '$ p' | cut -d ':' -f 1) - ${audio_begin[$i]}))
	done
	else
	audio_begin[1]=1
	audio_length[1]=1
fi
text_number=$(echo "$info" | grep -c "^Text")
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
general_info=$(echo "$info" | sed -n "1,$((${vedio_begin}-1)) p")
video_info=$(echo "$info" | sed -n "$vedio_begin,$(($vedio_begin+$vedio_length)) p")
audio_info=$(echo "$info" | sed -n "${audio_begin[1]},$((${audio_begin[1]}+${audio_length[1]})) p")
video_width=$(echo "$video_info" | grep "^Width  " | sed -e "s/[[:alpha:]]//g" -e "s/ //g" -e "s/://g")
video_high=$(echo "$video_info" | grep "^Height  " | sed -e "s/[[:alpha:]]//g" -e "s/ //g" -e "s/://g")

date=$(date +%Y%m%d-%H%M%S)

##手动截图部分
if [ -n "$manual_time" ]; then
	test -e "$picturepath/$date-$filename" || mkdir "$picturepath/$date-$filename"
	test -e "$logpath/$date-$filename" || mkdir "$logpath/$date-$filename"
	manual_time_forname=$(echo ${manual_time%%.*} | sed -e "s/://g")
	if [ -z "$separate_width" ]; then
		ffmpeg -ss "$manual_time" -i "$filepath" -frames:v 1 "$picturepath/$date-$filename/$filename-$manual_time_forname.png"
		if [ "$?" -eq "0" ]; then
			manual_png_success=1
		else
			echo "manual screenshot png generate fail!"
			exit 1
		fi
	else
		separate_high=$(echo "scale=5;$video_high/$video_width*$separate_width" | bc | cut -d "." -f 1)
		ffmpeg -ss "$manual_time" -i "$filepath" -frames:v 1 -vf "scale=w=$separate_width:h=$separate_high" "$picturepath/$date-$filename/$filename-$manual_time_forname.png"
		if [ "$?" -eq "0" ]; then
			manual_png_success=1
		else
			echo "manual screenshot png generate fail!"
			exit 1
		fi
	fi
	#png生成
	if [ -n "$jpg_flag" ] && [ -n "$manual_png_success" ] ; then
		ffmpeg -i "$picturepath/$date-$filename/$filename-$manual_time_forname.png" -qscale:v 2 "$picturepath/$date-$filename/$filename-$manual_time_forname.jpg"
		if [ "$?" -eq "0" ]; then
			manual_jpg_success=1
		else
			echo "manual screenshot jpg generate fail!"
			exit 1
		fi
	fi
	#jpg生成
	
	if [ -n "$upload_img_flag" ]; then
		if [ -n "$manual_jpg_success" ] && [ -n "$jpg_flag" ]; then
		#上传jpg
			if [ -z "$token" ]; then
				manual_xml=$(curl -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-$manual_time_forname.jpg" https://sm.ms/api/v2/upload)
			else
				manual_xml=$(curl -H "Authorization: $token" -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-$manual_time_forname.jpg" https://sm.ms/api/v2/upload)
			fi
		fi
		
		if [ -n "$manual_png_success" ] && [ -z "$jpg_flag" ]; then
		#上传png
			if [ -z "$token" ]; then
				manual_xml=$(curl -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-$manual_time_forname.png" https://sm.ms/api/v2/upload)
			else
				manual_xml=$(curl -H "Authorization: $token" -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-$manual_time_forname.png" https://sm.ms/api/v2/upload)
			fi
		fi
	fi
fi
##手动截图结束

##自动number张分别截图
if [ -n "$number" ]; then
	duration_secends=$(echo "$(echo "$duration" | cut -d '.' -f 1 | cut -d ':' -f 1) * 3600 + $(echo "$duration" | cut -d '.' -f 1 | cut -d ':' -f 2) * 60 + $(echo "$duration" | cut -d '.' -f 1 | cut -d ':' -f 3)" | bc)
	
	test -e "$picturepath/$date-$filename" || mkdir "$picturepath/$date-$filename"
	test -e "$logpath/$date-$filename" || mkdir "$logpath/$date-$filename"
	
	#生成时间戳
	genok=N
	while [ "$genok" = "n" ] || [ "$genok" = "N" ]
	do
		timestep=$(($duration_secends/($number+1)))
		for ((i=1;i<=$number;i=i+1))
		do
			capture_times[$i]=$(($timestep*$i))
		done
		echo "Take video capture at:"
		for ((i=1;i<=$number;i=i+1))
		do
			if [ "$randomshift_flag" = "1" ]; then
				randomshift=$((($(cat /proc/sys/kernel/random/uuid | cksum | cut -d ' ' -f 1) % $timestep)-($timestep/2)))
				capture_times[$i]=$((${capture_times[$i]}+$randomshift))
			fi
			h=$((${capture_times[$i]} / 3600))
			m=$((${capture_times[$i]} % 3600 / 60))
			s=$((${capture_times[$i]} % 60))
			capture_times[$i]=$(printf "%02d:%02d:%02d\n" $h $m $s)
		done
		echo ${capture_times[@]}
		read -p "Accept? (Type y or wait 5s to accept, type n to retry):" -t 5 genok
	done
	
	for ((i=1;i<=$number;i=i+1))
	do
		capture_times_for_name[$i]=$(echo ${capture_times[$i]} | sed "s/://g")
		if [ -z "$separate_width" ]; then
			ffmpeg -ss "${capture_times[$i]}" -i "$filepath" -frames:v 1 "$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.png"
			if [ "$?" -eq "0" ]; then
				auto_png_success[$i]=1
			fi
		else
			separate_high=$(echo "scale=5;$video_high/$video_width*$separate_width" | bc | cut -d "." -f 1)
			ffmpeg -ss "${capture_times[$i]}" -i "$filepath" -frames:v 1 -vf "scale=w=$separate_width:h=$separate_high" "$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.png"
			if [ "$?" -eq "0" ]; then
				auto_png_success[$i]=1
			fi
		fi

		if [ -n "$jpg_flag" ] && [ -n "${auto_png_success[$i]}" ] ; then
			ffmpeg -i "$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.png" -qscale:v 2 "$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.jpg"
			if [ "$?" -eq "0" ]; then
				auto_jpg_success[$i]=1
			fi
		fi
		if [ -n "$upload_img_flag" ]; then
			#jpg上传
			if [ -n "${auto_jpg_success[$i]}" ] && [ -n "$jpg_flag" ]; then
				if [ -z "$token" ]; then
					autogen_xml[$i]=$(curl -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.jpg" https://sm.ms/api/v2/upload)
				else
					autogen_xml[$i]=$(curl -H "Authorization: $token" -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.jpg" https://sm.ms/api/v2/upload)
				fi
			fi
			#png上传
			if [ -n "${auto_png_success[$i]}" ] && [ -z "$jpg_flag" ]; then
				if [ -z "$token" ]; then
					autogen_xml[$i]=$(curl -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.png" https://sm.ms/api/v2/upload)
				else
					autogen_xml[$i]=$(curl -H "Authorization: $token" -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-${capture_times_for_name[$i]}.png" https://sm.ms/api/v2/upload)
				fi
			fi
		fi
	done
fi

unset capture_times capture_times_sorted h m s genok

##缩略图生成部分
if [ -n "$mosaic_x" ] && [ -n "$mosaic_y" ]; then
	test -e "$picturepath/$date-$filename" || mkdir "$picturepath/$date-$filename"
	test -e "$logpath/$date-$filename" || mkdir "$logpath/$date-$filename"
	# test -e "$tmppath" || mkdir "$tmppath"
	duration_secends=$(echo "$(echo "$duration" | cut -d '.' -f 1 | cut -d ':' -f 1) * 3600 + $(echo "$duration" | cut -d '.' -f 1 | cut -d ':' -f 2) * 60 + $(echo "$duration" | cut -d '.' -f 1 | cut -d ':' -f 3)" | bc)
	mosaic_number=$(($mosaic_x*$mosaic_y))
	genok=N
	while [ "$genok" = "n" ] || [ "$genok" = "N" ]
	do
		timestep=$(($duration_secends/($mosaic_number+1)))
		for ((i=1;i<=$mosaic_number;i=i+1))
		do
			capture_times[$i]=$(($timestep*$i))
		done
		echo "Take video capture at:"
		for ((i=1;i<=$mosaic_number;i=i+1))
		do
			if [ "$randomshift_flag" = "1" ]; then
				randomshift=$((($(cat /proc/sys/kernel/random/uuid | cksum | cut -d ' ' -f 1) % $timestep)-($timestep/2)))
				capture_times[$i]=$((${capture_times[$i]}+$randomshift))
			fi
			h=$((${capture_times[$i]} / 3600))
			m=$((${capture_times[$i]} % 3600 / 60))
			s=$((${capture_times[$i]} % 60))
			capture_times[$i]=$(printf "%02d:%02d:%02d\n" $h $m $s)
		done
		echo ${capture_times[@]}
		read -p "Accept? (Type y or wait 5s to accept, type n to retry):" -t 5 genok
	done
	if [ -z "$mosaic_width" ]; then
		single_width=$video_width
		single_high=$video_high
	else
		single_width=$mosaic_width
		single_high=$(echo "scale=5;$video_high/$video_width*$single_width" | bc | cut -d "." -f 1)
	fi
	
	texthead=$(echo "scale=5;7*$fontsize+10" | bc | cut -d "." -f 1)
	base_width="$(($single_width*$mosaic_x+$gap*($mosaic_x+1)))"
	base_high="$(($single_high*$mosaic_y+$gap*($mosaic_y+1)+$texthead))"
	
	ffmpeg_base="color=size=${base_width}x${base_high}:c=$backgroundcolor[base];"
	
	ffmpeg_filteroverlay="[base]"
	for ((j=1;j<=$mosaic_y;j=j+1))
	do
		for ((i=1;i<=$mosaic_x;i=i+1))
		do
			k=$(($i+($j-1)*$mosaic_x))
			ffmpeg_input="$ffmpeg_input -ss ${capture_times[$k]} -t 1 -i $filepath"
			ffmpeg_filtermap="$ffmpeg_filtermap [$(($k-1)):v] setpts=PTS-STARTPTS, scale=w=$single_width:h=$single_high [input$k];"
			ffmpeg_filteroverlay="$ffmpeg_filteroverlay [input$k] overlay=shortest=1:x=$(($single_width*($i-1)+($gap*$i))):y=$(($single_high*($j-1)+($gap*$j)+$texthead)) [overlayout$k];[overlayout$k]"
		done
	done
	
	#logo部分
	if [ -f "$logofile" ]; then
		ffmpeg_input="$ffmpeg_input -i $logofile"
		logo_resolution=$(mediainfo --Inform="Image;%Width% %Height%" $logofile)
		logo_h="$(($texthead-$gap))"
		logo_w=$(echo "scale=5;$(echo "$logo_resolution" | cut -d " " -f 1)/$(echo "$logo_resolution" | cut -d " " -f 2)*$logo_h" | bc | cut -d "." -f 1)
		ffmpeg_filtermap="$ffmpeg_filtermap [$mosaic_number:v] setpts=PTS-STARTPTS ,scale=w=$logo_w:h=$logo_h [logo];"
		ffmpeg_filteroverlay="$ffmpeg_filteroverlay [logo] overlay=shortest=1:x=$(($base_width-$logo_w-$gap)):y=$gap [logooutput];[logooutput]"
	fi
	
	#logo部分结束
	
	# 文字部分：
	tmpfile=$(cat /proc/sys/kernel/random/uuid)
	echo "File Name : $filename" >> /tmp/$tmpfile
	echo "File Size : $(echo "$general_info" | grep "^File size  " | cut -d ":" -f 2 | sed -e "s/ //g")" >> /tmp/$tmpfile
	echo "Resolution: ${video_width}x${video_high} / $(echo "$video_info" | grep "^Frame rate  " | cut -d ":" -f 2 | sed -e "s/ //g")" >> /tmp/$tmpfile
	echo "Duration  : $duration" >> /tmp/$tmpfile
	echo "Video     : $(echo "$video_info" | grep "^Format  " | cut -d ":" -f 2 | sed -e "s/ //g")($(echo "$video_info" | grep "^Format profile  " | cut -d ":" -f 2 | sed -e "s/ //g")),$(echo "$video_info" | grep "^Bit rate  " | cut -d ":" -f 2 | sed -e "s/ //g")" >> /tmp/$tmpfile
	echo "Audio     : $(echo "$audio_info" | grep "^Format  " | cut -d ":" -f 2 | sed -e "s/^ *//g"),$(echo "$audio_info" | grep "^Bit rate  " | cut -d ":" -f 2 | sed -e "s/ //g"),$(echo "$audio_info" | grep "^Channel(s)  " | cut -d ":" -f 2 | sed -e "s/ //g")" >> /tmp/$tmpfile
	echo "Comment   : $comment" >> /tmp/$tmpfile
	
	ffmpeg_filteroverlay="$ffmpeg_filteroverlay drawtext=fontcolor=$fontcolor:x=$gap:y=$gap:textfile=/tmp/$tmpfile:fontsize=$fontsize:font=\'$font\':shadowx=$font_shadowx:shadowy=$font_shadowy: shadowcolor=$font_shadowcolor[fontout];[fontout]"

	# 文字部分结束
	
	# 时间戳部分
	
	if [ "$require_timestamp" = "1" ]; then
		for ((j=1;j<=$mosaic_y;j=j+1))
		do
			for ((i=1;i<=$mosaic_x;i=i+1))
			do
				k=$(($i+($j-1)*$mosaic_x))
				capture_timestamp=$(echo "${capture_times[$k]}" | sed -e 's/:/\\:/g')
				ffmpeg_filteroverlay="$ffmpeg_filteroverlay drawtext=font=\'$timestamp_font\':fontcolor=$timestamp_fontcolor:text=\'$capture_timestamp\':fontsize=$timestamp_fontsize:shadowx=$timestamp_shadowx:shadowy=$timestamp_shadowy:shadowcolor=$timestamp_shadowcolor:x=$(($single_width*($i-1)+($gap*$i)))+($single_width-tw)*$timestamp_x:y=$(($single_high*($j-1)+($gap*$j)+$texthead))+($single_high-th)*$timestamp_y[timestamp$k];[timestamp$k]"
				
			done
		done
	fi
	
	
	# 时间戳结束
	
	ffmpeg_filteroverlay=${ffmpeg_filteroverlay%\[*\];\[*\]}
	
	ffmpeg $ffmpeg_input -filter_complex "$ffmpeg_base $ffmpeg_filtermap $ffmpeg_filteroverlay" -frames:v 1 "$picturepath/$date-$filename/$filename-mosaic.png"
	
	rm /tmp/$tmpfile
	if [ "$?" -ne "0" ]; then
		echo "mosaic png generate fail!"
		exit 1
	fi
	
	if [ -n "$jpg_flag" ]; then
		ffmpeg -i "$picturepath/$date-$filename/$filename-mosaic.png" -qscale:v 2 "$picturepath/$date-$filename/$filename-mosaic.jpg"
		if [ "$?" -ne "0" ]; then
			echo "mosaic jpg generate fail!"
			exit 1
		fi
	fi
	if [ -n "$upload_img_flag" ]; then
		#jpg上传
		if [ -n "$jpg_flag" ]; then
			if [ -z "$token" ]; then
				mosaic_xml=$(curl -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-mosaic.jpg" https://sm.ms/api/v2/upload)
			else
				mosaic_xml=$(curl -H "Authorization: $token" -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-mosaic.jpg" https://sm.ms/api/v2/upload)
			fi
		else
			if [ -z "$token" ]; then
				mosaic_xml=$(curl -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-mosaic.png" https://sm.ms/api/v2/upload)
			else
				mosaic_xml=$(curl -H "Authorization: $token" -X POST -F 'format=xml' -F "smfile=@$picturepath/$date-$filename/$filename-mosaic.png" https://sm.ms/api/v2/upload)
			fi
		fi
	fi
fi

if [ -z "$slience_flag" ]; then
	test -e "$logpath/$date-$filename" || mkdir "$logpath/$date-$filename"
	echo "$info" >> "$logpath/$date-$filename/$filename-full.nfo"
	echo "Brief information:"
	echo "★★★★★ General Information ★★★★★" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "File Name............: $(basename $(echo "$general_info" | grep "^Complete name  " | cut -d ':' -f 2))" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "File Size............: $(echo "$general_info" | grep "^File size  " | cut -d ':' -f 2| sed "s/ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "Duration.............: $duration (HH:MM:SS.MMM)" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "Video Bit Rate.......: $(echo "$video_info" | grep "^Bit rate  " | cut -d ':' -f 2 | sed "s/ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "Video Codec..........: $(echo "$video_info" | grep "^Format  " | cut -d ':' -f 2 | sed "s/ //g"),$(echo "$video_info" | grep "^Format profile" | cut -d ':' -f 2 | sed "s/ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "Frame Rate...........: $(echo "$video_info" | grep "^Frame rate  " | cut -d ':' -f 2 | sed "s/ //g" | sed "s/(.*)//g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	echo "Resolution...........: $(echo "$video_info" | grep "^Width  " | cut -d ':' -f 2 | sed -e "s/ //g" -e "s/pixels//g")x$(echo "$video_info" | grep "^Height  " | cut -d ':' -f 2 | sed -e "s/ //g" -e "s/pixels//g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	
	if [ "$audio_number" = "1" ]; then
	
	echo "Audio................: [$(echo "$audio_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$audio_info" | grep "^Title  " | cut -d ":" -f 2 | sed "s/^ //g") $(echo "$audio_info" | grep "^Bit rate  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Channel(s)  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Format  " | cut -d ":" -f 2 | sed "s/^ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	fi

	if [ "$audio_number" -gt "1" ]; then
	for ((i = 1; i <= ${audio_number}; i=i+1))
	do
		audio_info=$(echo "$info" | sed -n "${audio_begin[$i]},$((${audio_begin[$i]}+${audio_length[$i]})) p")
		printf "Audio#%02d" $i | tee -a "$logpath/$date-$filename/$filename.nfo"
		echo ".............: [$(echo "$audio_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$audio_info" | grep "^Title  " | cut -d ":" -f 2 | sed "s/^ //g") $(echo "$audio_info" | grep "^Bit rate  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Channel(s)  " | cut -d ":" -f 2 | sed "s/ //g") $(echo "$audio_info" | grep "^Format  " | cut -d ":" -f 2 | sed "s/^ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	done
	fi

	if [ "$text_number" = "1" ]; then
	text_info=$(echo "$info" | sed -n "${text_begin[1]},$((${text_begin[1]}+${text_length[1]})) p")
	echo "Subtitle.............: [$(echo "$text_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$text_info" | grep "^Title   " | cut -d ':' -f 2 | sed "s/ //g") $(echo "$text_info" | grep "^Codec ID  " | cut -d ':' -f 2 | sed "s/ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	fi

	if [ "$text_number" -gt "1" ]; then
	for ((i = 1; i <= ${text_number}; i=i+1))
	do
		text_info=$(echo "$info" | sed -n "${text_begin[$i]},$((${text_begin[$i]}+${text_length[$i]})) p")
		printf "Subtitle#%02d" $i | tee -a "$logpath/$date-$filename/$filename.nfo"
		echo "..........: [$(echo "$text_info" | grep "^Language  " | cut -d ':' -f 2 | sed "s/ //g")] $(echo "$text_info" | grep "^Title   " | cut -d ':' -f 2 | sed "s/ //g") $(echo "$text_info" | grep "^Codec ID  " | cut -d ':' -f 2 | sed "s/ //g")" | tee -a "$logpath/$date-$filename/$filename.nfo"
	done
	fi
	
fi

if [ -n "$upload_img_flag" ]; then
	echo "Screenshot upload records at $(date +%Y%m%d-%H:%M:%S)" >> "$logpath/$date-$filename/imgupload.txt"
	if [ -n "$manual_time" ]; then
		message=$(echo "$manual_xml" | grep "<message>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
		echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
		echo "Manual screenshot:" | tee -a "$logpath/$date-$filename/imgupload.txt"
		echo "$message" | tee -a "$logpath/$date-$filename/imgupload.txt"
		if [ "$message" = "Upload success." ]; then
			manual_url=$(echo "$manual_xml" | grep "<url>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			manual_page=$(echo "$manual_xml" | grep "<page>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			manual_delete=$(echo "$manual_xml" | grep "<delete>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			manual_filename=$(echo "$manual_xml" | grep "<filename>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			echo "$manual_filename:"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "URL:    $manual_url"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "Page:   $manual_page"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "Delete: $manual_delete"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "BBCode: [url=$manual_page][img]$manual_url[/img][/url]"| tee -a "$logpath/$date-$filename/imgupload.txt"
			else
			echo "Upload fail!"| tee -a "$logpath/$date-$filename/imgupload.txt"
		fi
		echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
	fi
	if [ -n "$number" ]; then
		for ((i=1;i<=$number;i=i+1))
		do
			message=$(echo "${autogen_xml[$i]}" | grep "<message>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "Auto screenshot #$i:" | tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "$message" | tee -a "$logpath/$date-$filename/imgupload.txt"
			if [ "$message" = "Upload success." ]; then
				auto_url[$i]=$(echo "${autogen_xml[$i]}" | grep "<url>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
				auto_page[$i]=$(echo "${autogen_xml[$i]}" | grep "<page>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
				auto_delete[$i]=$(echo "${autogen_xml[$i]}" | grep "<delete>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
				auto_filename[$i]=$(echo "${autogen_xml[$i]}" | grep "<filename>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
				echo "${auto_filename[$i]}:"| tee -a "$logpath/$date-$filename/imgupload.txt"
				echo "URL:    ${auto_url[$i]}"| tee -a "$logpath/$date-$filename/imgupload.txt"
				echo "Page:   ${auto_page[$i]}"| tee -a "$logpath/$date-$filename/imgupload.txt"
				echo "Delete: ${auto_delete[$i]}"| tee -a "$logpath/$date-$filename/imgupload.txt"
				echo "BBCode: [url=${auto_page[$i]}][img]${auto_url[$i]}[/img][/url]"| tee -a "$logpath/$date-$filename/imgupload.txt"
				else
				echo "Upload fail!"| tee -a "$logpath/$date-$filename/imgupload.txt"
			fi
			echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
		done
	fi
	if [ -n "$mosaic_x" ]; then
		message=$(echo "${mosaic_xml}" | grep "<message>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
		echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
		echo "Mosaic screenshot:" | tee -a "$logpath/$date-$filename/imgupload.txt"
		echo "$message" | tee -a "$logpath/$date-$filename/imgupload.txt"
		if [ "$message" = "Upload success." ]; then
			mosaic_url=$(echo "$mosaic_xml" | grep "<url>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			mosaic_page=$(echo "$mosaic_xml" | grep "<page>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			mosaic_delete=$(echo "$mosaic_xml" | grep "<delete>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			mosaic_filename=$(echo "$mosaic_xml" | grep "<filename>" | sed -e "s/<[[:alpha:]]*>//g" -e "s/<\/[[:alpha:]]*>//g" -e "s/^[[:blank:]]*//g")
			echo "$mosaic_filename:"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "URL:    $mosaic_url"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "Page:   $mosaic_page"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "Delete: $mosaic_delete"| tee -a "$logpath/$date-$filename/imgupload.txt"
			echo "BBCode: [url=$mosaic_page][img]$mosaic_url[/img][/url]"| tee -a "$logpath/$date-$filename/imgupload.txt"
			else
			echo "Upload fail!"| tee -a "$logpath/$date-$filename/imgupload.txt"
		fi
		echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
	fi
	
	echo "Summary" | tee -a "$logpath/$date-$filename/imgupload.txt"
	echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
	
	echo "URL:" | tee -a "$logpath/$date-$filename/imgupload.txt"
	test -n "$manual_url" && echo "$manual_url" | tee -a "$logpath/$date-$filename/imgupload.txt"
	if [ -n "$number" ]; then
		for ((i=1;i<=$number;i=i+1))
		do
			test -n "${auto_url[$i]}" && echo "${auto_url[$i]}" | tee -a "$logpath/$date-$filename/imgupload.txt"
		done
	fi
	test -n "$mosaic_url" && echo "$mosaic_url" | tee -a "$logpath/$date-$filename/imgupload.txt"
	echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
	
	echo "Page:" | tee -a "$logpath/$date-$filename/imgupload.txt"
	test -n "$manual_page" && echo "$manual_page" | tee -a "$logpath/$date-$filename/imgupload.txt"
	if [ -n "$number" ]; then
		for ((i=1;i<=$number;i=i+1))
		do
			test -n "${auto_page[$i]}" && echo "${auto_page[$i]}" | tee -a "$logpath/$date-$filename/imgupload.txt"
		done
	fi
	test -n "$mosaic_page" && echo "$mosaic_page" | tee -a "$logpath/$date-$filename/imgupload.txt"
	echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
	
	echo "Delete:" | tee -a "$logpath/$date-$filename/imgupload.txt"
	test -n "$manual_delete" && echo "$manual_delete" | tee -a "$logpath/$date-$filename/imgupload.txt"
	if [ -n "$number" ]; then
		for ((i=1;i<=$number;i=i+1))
		do
			test -n "${auto_delete[$i]}" && echo "${auto_delete[$i]}" | tee -a "$logpath/$date-$filename/imgupload.txt"
		done
	fi
	test -n "$mosaic_delete" && echo "$mosaic_delete" | tee -a "$logpath/$date-$filename/imgupload.txt"
	echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
	
	echo "BBCode:" | tee -a "$logpath/$date-$filename/imgupload.txt"
	test -n "$manual_url" && echo "[url=$manual_page][img]$manual_url[/img][/url]" | tee -a "$logpath/$date-$filename/imgupload.txt"
	if [ -n "$number" ]; then
		for ((i=1;i<=$number;i=i+1))
		do
			test -n "${auto_url[$i]}" && echo "[url=${auto_page[$i]}][img]${auto_url[$i]}[/img][/url]" | tee -a "$logpath/$date-$filename/imgupload.txt"
		done
	fi
	test -n "$mosaic_url" && echo "[url=$mosaic_page][img]$mosaic_url[/img][/url]" | tee -a "$logpath/$date-$filename/imgupload.txt"
	echo "-------------------------------------------------------------------------------------------------------------------" | tee -a "$logpath/$date-$filename/imgupload.txt"
fi

if [ -z "$slience_flag" ]; then
	echo "Vedio info saved to $logpath/$date-$filename"
fi

if [ -n "$manual_time" ] || [ -n "$number" ] || [ -n "$mosaic_x" ] ; then
	echo "Pictures saved to $picturepath/$date-$filename"
fi
if [ -n "$upload_img_flag" ]; then
	echo "Upload log saved to $logpath/$date-$filename"
fi
