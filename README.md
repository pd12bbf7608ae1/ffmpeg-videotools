# ffmpeg-videotools

使用 ffmpeg 、mediainfo 和 curl 进行视频文件信息生成、视频截图生成与上传sm.ms图床的bash脚本工具。

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

在脚本文件前有一系列的参数设置，至少需要修改：
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
输出视频文件的信息并保存

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

