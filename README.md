# ffmpeg-videotools

使用 ffmpeg 、mediainfo 和 curl 进行视频文件信息生成、视频截图生成与上传sm.ms图床的bash脚本工具。

## 使用效果

以下为对样例文件进行使用的结果输出：

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

截图效果可以参考[Examplefile](https://github.com/pdxgf1208/ffmpeg-videotools/tree/master/Examplefile "Examplefile")中的文件。

## 依赖安装

脚本依赖 ffmpeg、mediainfo、curl、bc 命令。

### Ubuntu 系统

Ubuntu 系统内置了curl与bc命令，官方软件仓库拥有 ffmpeg 与 mediainfo 的安装包，可以使用apt工具安装。

```shell
sudo apt install ffmpeg mediainfo
```

以上操作在 Ubuntu 18.04 Server 与 Ubuntu 19.10 Server 系统测试。

### CentOS 系统

CentOS 系统在最小安装环境下内置curl命令，官方仓库有 mediainfo 安装包，ffmpeg 需要从 RPM Fusion 源安装。下面给出使用中科大镜像源的安装方法。

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

以上操作在 CentOS 7 系统测试。

## 使用脚本前的建议

### 修改脚本的参数

在脚本文件前有一系列的参数设置，后面有详细说明，至少需要修改：
- picturepath (截图保存目录)
- logpath (信息保存目录)

这两个选项，以便脚本保存相关信息，默认两个目录均为：

`$HOME/Pictures/VedioCapture`

请按照个人的习惯进行修改，并保证脚本使用者对该目录有写入的权限。

### 将脚本保存位置添加到 PATH 变量中并增加执行权限

这有利于从任何文件夹方便调用本脚本。

### 去 sm.ms 图床注册个账号

虽然使用匿名上传也是可行的，但上传后会难以对图片进行管理（需要查看相关日志）。
注册完毕后在 https://sm.ms/home/apitoken 中生成 token 填入 token 变量中以便将文件保存在你的账户下。

## 用法

假定脚本文件放入`$PATH`目录下并命名为`videotools.sh`

`videotools.sh <video file path> [options...]`

或者

`videotools.sh [options...] <video file path>`

第二种用法在一些系统中会失效（脚本无法获取最后一个参数）。

### 参数列表

|选项|描述|
| ------------ | ------------ |
|`-h`|打印帮助信息|
|`-j`|将输出的 png 图像转换为 jpg 格式（无该选项则仅输出 png ）|
|`-m <横向数量>x<纵向数量>`|指定将多个截图合并到一张图片的排列格式（不指定则不输出）|
|`-M <时间>`|指定手动截图的时间参数,格式同 `ffmpeg` 时间格式|
|`-n <图片数量>`|指定输出单独截图的数目（不指定则不输出）|
|`-s`|屏蔽视频信息输出（仅截图）|
|`-u`|将截图上传至 sm.ms 图床（`-j`存在时上传 jpg 格式，否则为 png 格式）|
|`-w <像素数量>`|指定`-m`参数中单张截图的宽度，不指定则使用视频原始分辨率|
|`-W <像素数量>`|指定`-M`与`-n`参数中单张截图的宽度，不指定则使用视频原始分辨率|

### 例子

`videotools.sh <video file path>`

输出视频文件的信息并保存。

`videotools.sh <video file path> -M 00:10:10 -sjuW 1280`

屏蔽视频文件的信息输出，在时间`00:10:00`处以`1280`宽的分辨率截图，转换为 jpg 格式并上传 sm.ms 图床。

`videotools.sh <video file path> -m 4x4 -suw 500`

屏蔽视频文件的信息输出，以`4x4`的格式生成缩略图，单张截图宽`500`，并将生成图片上传 sm.ms 图床。

`videotools.sh <video file path> -n 3 -m 3x3 -ujw 500`

输出视频文件的信息并保存，以视频分辨率生成3张独立的截图，以`3x3`的格式生成缩略图，单张截图宽`500`，并将生成图片上传 sm.ms 图床。

### 常数列表

脚本执行前有一些常数的设置，以下为它们的作用。

|选项|描述|
| ------------ | ------------ |
|`picturepath`|截图保存位置|
|`logpath`|视频信息和截图上传信息保存位置|
|`randomshift_flag`|自动选取时间时是否加入随机偏移，为`0`或不存在使用固定值，影响`-n`与`-m`参数生成的截图|
|`logofile`|缩略图中的logo文件位置，留空为不使用logo|
|`gap`|缩略图中的间隙参数，单位像素|
|`comment`|缩略图中的Comment字段|
|`font`|缩略图中顶端说明文字字体|
|`fontsize`|缩略图中顶端说明文字字号|
|`fontcolor`|缩略图中顶端说明文字颜色|
|`font_shadowcolor`|缩略图中顶端说明文字阴影颜色|
|`font_shadowx`|缩略图中顶端说明文字阴影x偏移|
|`font_shadowy`|缩略图中顶端说明文字阴影y偏移|
|`require_timestamp`|缩略图中时间戳开关，非`1`或者不存在为不生成|
|`timestamp_fontcolor`|缩略图中时间戳文字颜色|
|`timestamp_shadowcolor`|缩略图中时间戳文字阴影颜色|
|`timestamp_font`|缩略图中时间戳文字字体|
|`timestamp_fontsize`|缩略图中时间戳文字字号|
|`timestamp_shadowx`|缩略图中时间戳文字阴影x偏移|
|`timestamp_shadowy`|缩略图中时间戳文字阴影y偏移|
|`timestamp_x`|缩略图中时间戳文字位于该截图x位置的比例，如`0.5`在截图中央|
|`timestamp_y`|缩略图中时间戳文字位于该截图y位置的比例，如`0.5`在截图中央|
|`backgroundcolor`|缩略图背景颜色|
|`token`|`sm.ms`图床`apikey`,留空使用匿名上传|

其中有关颜色的定义请参考[FFmpeg颜色定义](https://www.ffmpeg.org/ffmpeg-all.html#Color "FFmpeg颜色定义")，有关字体相关参数具体说明请参考[FFmpeg drawtext参数列表](https://www.ffmpeg.org/ffmpeg-all.html#drawtext-1 "FFmpeg drawtext参数列表")。

## 使用注意事项

1. 使用`-m`参数需注意，生成缩略图分辨率过大容易导致内存不足而失败；
1. 使用过旧版本`FFmpeg`可能导致脚本部分功能失效；
1. 使用上传功能时建议搭配`-j`参数使用，以免因生成`png`格式图片过大，超过`sm.ms`图床上传限制而失败；
1. 使用上传功能时请遵守`sm.ms`[使用协议](https://sm.ms/about "使用协议")。

## 致谢

1. 感谢[FFmpeg](https://www.ffmpeg.org/ "FFmpeg")提供的强大视频处理工具和详尽的[Wiki](https://trac.ffmpeg.org/wiki "Wiki")文档；
1. 感谢[MediaInfo](https://mediaarea.net/en/MediaInfo "MediaInfo")提供的视频信息提取工具;
1. 感谢[sm.ms图床](https://sm.ms/ "sm.ms图床")提供的免费、可靠服务和易用的[API](https://doc.sm.ms/ "API")；
1. 感谢[中国科学技术大学开源软件镜像站](https://mirrors.ustc.edu.cn/ "中国科学技术大学开源软件镜像站")提供的软件镜像服务和帮助文档。

## 许可

这个项目是在MIT许可下进行的 - 查看 [LICENSE](https://github.com/pdxgf1208/ffmpeg-videotools/blob/master/LICENSE "LICENSE") 文件获取更多详情。

