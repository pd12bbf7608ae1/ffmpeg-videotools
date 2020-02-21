# ffmpeg-videotools

A shell script using mediainfo, ffmpeg and curl to generate vedio information, snapshot and upload to sm.ms image host.

## Use effect

The following is the output from the sample file:

    Brief information:
    ★★★★★ General Information ★★★★★
    File Name............: Snow.White.and.the.Seven.Dwarfs.1937.mp4
    File Size............: 174MiB
    Duration.............: 00:17:29.966 (HH:MM:SS.MMM)
    Video Bit Rate.......: 1066kb/s
    Video Codec..........: AVC,Main@L3.1
    Frame Rate...........: 23.976FPS
    Resolution...........: 720x536
    Audio................: [English]  317kb/s 2channels AAC LC
    -------------------------------------------------------------------------------------------------------------------
    Auto screenshot #1:
    Upload success.
    Snow.White.and.the.Seven.Dwarfs.1937.mp4-000335.jpg:
    URL:    https://i.loli.net/2020/02/21/sCPuIxzQSl61vLw.jpg
    Page:   https://sm.ms/image/sCPuIxzQSl61vLw
    Delete: https://sm.ms/delete/KkIEGrwoxpdOcQX45qiWT1UtL6
    BBCode: [url=https://sm.ms/image/sCPuIxzQSl61vLw][img]https://i.loli.net/2020/02/21/sCPuIxzQSl61vLw.jpg[/img][/url]
    -------------------------------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------
    Auto screenshot #2:
    Upload success.
    Snow.White.and.the.Seven.Dwarfs.1937.mp4-001402.jpg:
    URL:    https://i.loli.net/2020/02/21/d5PLRGcqSaBJwpn.jpg
    Page:   https://sm.ms/image/d5PLRGcqSaBJwpn
    Delete: https://sm.ms/delete/OSG7HrdEBjWc8efwVMYUmkAoQP
    BBCode: [url=https://sm.ms/image/d5PLRGcqSaBJwpn][img]https://i.loli.net/2020/02/21/d5PLRGcqSaBJwpn.jpg[/img][/url]
    -------------------------------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------
    Mosaic screenshot:
    Upload success.
    Snow.White.and.the.Seven.Dwarfs.1937.mp4-mosaic.jpg:
    URL:    https://i.loli.net/2020/02/21/ahWRUKlzdwkSvQ1.jpg
    Page:   https://sm.ms/image/ahWRUKlzdwkSvQ1
    Delete: https://sm.ms/delete/kg9Gh3UVMX6Fx2c5AZwTe4YRpo
    BBCode: [url=https://sm.ms/image/ahWRUKlzdwkSvQ1][img]https://i.loli.net/2020/02/21/ahWRUKlzdwkSvQ1.jpg[/img][/url]
    -------------------------------------------------------------------------------------------------------------------
    Summary
    -------------------------------------------------------------------------------------------------------------------
    URL:
    https://i.loli.net/2020/02/21/sCPuIxzQSl61vLw.jpg
    https://i.loli.net/2020/02/21/d5PLRGcqSaBJwpn.jpg
    https://i.loli.net/2020/02/21/ahWRUKlzdwkSvQ1.jpg
    -------------------------------------------------------------------------------------------------------------------
    Page:
    https://sm.ms/image/sCPuIxzQSl61vLw
    https://sm.ms/image/d5PLRGcqSaBJwpn
    https://sm.ms/image/ahWRUKlzdwkSvQ1
    -------------------------------------------------------------------------------------------------------------------
    Delete:
    https://sm.ms/delete/KkIEGrwoxpdOcQX45qiWT1UtL6
    https://sm.ms/delete/OSG7HrdEBjWc8efwVMYUmkAoQP
    https://sm.ms/delete/kg9Gh3UVMX6Fx2c5AZwTe4YRpo
    -------------------------------------------------------------------------------------------------------------------
    BBCode:
    [url=https://sm.ms/image/sCPuIxzQSl61vLw][img]https://i.loli.net/2020/02/21/sCPuIxzQSl61vLw.jpg[/img][/url]
    [url=https://sm.ms/image/d5PLRGcqSaBJwpn][img]https://i.loli.net/2020/02/21/d5PLRGcqSaBJwpn.jpg[/img][/url]
    [url=https://sm.ms/image/ahWRUKlzdwkSvQ1][img]https://i.loli.net/2020/02/21/ahWRUKlzdwkSvQ1.jpg[/img][/url]
    -------------------------------------------------------------------------------------------------------------------
    Vedio info saved to /home/ubuntu/Pictures/VedioCapture/20200221-115213-Snow.White.and.the.Seven.Dwarfs.1937.mp4
    Pictures saved to /home/ubuntu/Pictures/VedioCapture/20200221-115213-Snow.White.and.the.Seven.Dwarfs.1937.mp4
    Upload log saved to /home/ubuntu/Pictures/VedioCapture/20200221-115213-Snow.White.and.the.Seven.Dwarfs.1937.mp4

The screenshots can be referred to [Examplefile](https://github.com/pdxgf1208/ffmpeg-videotools/tree/master/Examplefile "Examplefile") .

## Install dependency softwares

The script uses ffmpeg, mediainfo, curl, bc software.

### Ubuntu

Just install ffmpeg and mediainfo with apt.

```shell
sudo apt install ffmpeg mediainfo
```

### CentOS

Install from rpmfusion.

The following command is how to install dependency softwares USTC open source software mirror.

```shell
sudo yum install -y epel-release
sudo sed -e 's!^mirrorlist=!#mirrorlist=!g' \
         -e 's!^#baseurl=!baseurl=!g' \
         -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
         -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
         -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
sudo yum localinstall --nogpgcheck https://mirrors.ustc.edu.cn/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.ustc.edu.cn/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
sudo yum install ffmpeg bc mediainfo
```

## Some advices before using this script

### Modify constants of this script

Constants at the start of this script need to be modified based on personal habits.
At least modify the following constants

- picturepath (Images save path)
- logpath (Logs save path)

The default path of both is:

`$HOME/Pictures/VedioCapture`

### Add path of this script to variable PATH

This will make it more convenient to use this script anywhere.

### Register an account in sm.ms

If you want to manager your picture convenient, it's better to have an account in sm.ms and generate your token from https://sm.ms/home/apitoken, and add it to `token` constant.

## Usage

Suppose the script file goes into the `$PATH` directory and is named as `videotools.sh`.

`videotools.sh <video file path> [options...]`

Or

`videotools.sh [options...] <video file path>`

The second usage fails on some systems (the script cannot get the last parameter).

### List of parameters

|Option|Description|
| ------------ | ------------ |
|`-h`|print help messages|
|`-j`|convert png to jpg (default is png format)|
|`-m <transverse number>x<longitudinal number>`|generate multiple screenshots to an image with the given tiles (empty means don't generate)|
|`-M <time>`|generate single screenshot at the given time|
|`-n <number>`|generate multiple screenshots with the given number (empty means don't generate)|
|`-s`|do not show and save video information|
|`-u`|upload images to sm.ms, default is png format, upload jpg format with -j option|
|`-w <number>`|set the width(in pixel) of screenshots in -M, -n options, default is the width of video|
|`-W <number>`|set the width(in pixel) of each screenshots in -m options, default is the width of video|

### Examples

`videotools.sh <video file path>`

show video information and save to txt file

`videotools.sh <video file path> -M 00:10:10 -sjuW 1280`

do not show and save video information, generate single screenshot at 00:10:10 with 1280 pixels width, convert screenshot to jpg format and upload it to sm.ms

`videotools.sh <video file path> -m 4x4 -suw 500`

do not show and save video information, generate 16 screenshots to an image, 500 pixels width for each screenshot, upload it to sm.ms

`videotools.sh <video file path> -n 3 -m 3x3 -ujw 500`

show video information and save to txt file, generate 3 screenshots with the same resolution of the video, generate 9 screenshots to an image, 500 pixels width for each screenshot, convert outputs to jpg format and upload to sm.ms

### List of constants

|Constant|Description|
| ------------ | ------------ |
|`picturepath`|screenshot save location|
|`logpath`|sideo information and screenshot upload information save location|
|`randomshift_flag`|whether to add random offset when the time is automatically selected,`0` or not exist means do not|
|`logofile`|location of logo file, empty means do not use logo|
|`gap`|gap between pictures in thumbnail|
|`comment`|`Comment` in thumbnail|
|`font`|font at the head of thumbnail|
|`fontsize`|fontsize at the head of thumbnail|
|`fontcolor`|fontcolor at the head of thumbnail|
|`font_shadowcolor`|font shadowcolor at the head of thumbnail|
|`font_shadowx`|font shadow x offset at the head of thumbnail|
|`font_shadowy`|font shadow y offset at the head of thumbnail|
|`require_timestamp`|timestamp switcher in the thumbnail|
|`timestamp_fontcolor`|timestamp fontcolor in the thumbnail|
|`timestamp_shadowcolor`|timestamp font shadowcolor in the thumbnail|
|`timestamp_font`|timestamp font shadowcolor in the thumbnail|
|`timestamp_fontsize`|timestamp fontsize in the thumbnail|
|`timestamp_shadowx`|timestamp shadow x offset in the thumbnail|
|`timestamp_shadowy`|timestamp shadow y offset in the thumbnail|
|`timestamp_x`|timestamp x location ratio in the thumbnail|
|`timestamp_y`|timestamp x location ratio in the thumbnail|
|`backgroundcolor`|thumbnail background color|
|`token`|`apikey` from `sm.ms`|

The definition of color is the same of FFmpeg's.

[Color definitions of FFmpeg](https://www.ffmpeg.org/ffmpeg-all.html#Color)

## Acknowledgements

1. Thanks [FFmpeg](https://www.ffmpeg.org/ "FFmpeg") and their [Wiki](https://trac.ffmpeg.org/wiki "Wiki");

1. Thanks [MediaInfo](https://mediaarea.net/en/MediaInfo "MediaInfo");

1. Thanks [sm.ms](https://sm.ms/ "sm.ms") and their [API](https://doc.sm.ms/ "API");

1. Thanks [USTC open source software mirror](https://mirrors.ustc.edu.cn/ "USTC open source software mirror").
