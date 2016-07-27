raspbian-tools
===

[![GitHub release](https://img.shields.io/github/release/CANDY-LINE/raspbian-tools.svg)](https://github.com/CANDY-LINE/raspbian-tools/releases/latest)
[![License MIT](https://img.shields.io/github/license/CANDY-LINE/raspbian-tools.svg)](http://opensource.org/licenses/MIT)

# ToC

* [Raspbian Flash Tool](#Raspbian Flash Tool)
* [Waiting for RPi's SSH to be available](#Waiting for RPi's SSH to be available)

# Raspbian Flash Tool

** CAUTION: USE AT YOUR OWN RISK, NOT RESPONSIBLE FOR ANY ACCIDENTS **

The script allows you to download and flash the latest version of Raspbian OS to your SD card. The downloaded image is stored in `img` folder (NOTE: the owner is `root` as the script is run as root) with ETag and Last-Modified information which is used for detecting the image update compared to the local one.

The size of SD card must be 8GB or more.

* KNOWN LIMITATIONS
    - This tool may not work properly when 2 or more SD cards are inserted to Mac
    - SD card is expected to be formatted with FAT32 or Linux file system

## Supported OS

- MacOS

## Usage

```
$ cd path/to/raspbian-tools
$ sudo ./raspbian-sd-flash-mac.sh
```

The script asks you if the selected disk is the SD card you'd like to install Raspbian.
Make sure it's a valid SD card and enter `y` then the installation will be started.

Please be careful to answer `y` because the selected disk will be erased and its data will be gone.

The command will take around 15 minutes (depending on SD card class).

### Example output

```
Password: (enter-your-password)
[INFO] Remote ETag ["c055d-53152af2-533d18ef29fc0"]
[INFO] Local ETag  ["c055d-53152af2-533d18ef29fc0"]
[INFO] Remote Last-Modified [Fri, 27 May 2016 11:53:43 GMT]
[INFO] Local Last-Modified  [Fri, 27 May 2016 11:53:43 GMT]
[INFO] IDENTICAL!! Skip to download
Archive:  ./img/raspbian_latest.zip
  inflating: ./img/2016-05-27-raspbian-jessie.img  
ls: ./img/*.ext4: No such file or directory
[INFO] I've found the following SD card.
/dev/disk2 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *4.0 GB     disk2
   1:             Windows_FAT_32 boot                    66.1 MB    disk2s1
   2:                      Linux                         3.9 GB     disk2s2
[ALERT] I'm going to flash Raspbian OS to the SD card. Are you sure to continue? (y/N)
y
[INFO] Got it. Now working...
Unmount of disk2 failed: at least one volume could not be unmounted
[INFO] Starting dd....
dd: /dev/rdisk2: short write on character device
dd: /dev/rdisk2: Input/output error
3782+0 records in
3781+1 records out
3965190144 bytes transferred in 789.804068 secs (5020473 bytes/sec)
[INFO] OK
```

## Tested Raspbian versions

* 2016-05-27

# Waiting for RPi's SSH to be available

The script tells you if SSH on your RPi is available.

## Supported OS

- MacOS
- Linux

## Usage

```
$ cd path/to/raspbian-tools
$ ./wait_for_rpi_ssh.sh
```

### Example output

```
[INFO] Looking for raspberrypi.local...
...
[INFO] Testing SSH to pi@raspberrypi.local
[INFO]
[INFO] OK
[INFO] SSH is ready. Run 'ssh pi@raspberrypi.local'
```

## Revision History
* 1.0.0
  - Initial Release
