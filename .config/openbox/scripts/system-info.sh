#!/bin/bash
######## This is a script made
######## by 'yettenet'.
########
######## SysInfo script for OpenBox
######## v0.1
########
######## The author does not take
######## any responsibility for
######## what it might do to your
######## computer, though it's
######## improbable to do any harm.
########
######## You may share the script with
######## everyone and modify it for your
######## liking, as long as you
######## GIVE CREDIT.
########
######## To add it to Openbox, copy it to
######## your Openbox/scripts folder, which usually is at
######## ~/.config/openbox/scripts
########
######## edit your menu.xml file, which usually is at
######## ~/.config/openbox/menu.xml
######## and add the following line (in case you have the usual paths - if not, edit the path as needed):
########
########<menu execute="~/.config/openbox/scripts/sysinfo_v01-by_yettenet.script" id="sysinfo-menu" label="SysInfo"/>
########
######## Below you will find the settings
######## (the script still needs to be tested)  

########  settings

MountPoint1=$(echo /dev/root)
MountPoint2=$(echo /dev/trekstor1)
MountPoint3=$(echo /dev/trekstor2)
MountPoint4=$(echo /dev/sda3)
MountPoint5=$(echo /media/crossfire)
#NetworkDevice1=$(echo eth0)
#NetworkDevice2=$(echo eth1)  #Uncomment some lines to make it work!

######## /settings


Signal=$(cat /sys/class/net/wlan0/wireless/link)
User=$(whoami)
Host=$(uname -n)
System=$(uname -s)
Release=$(uname -r)
Arch=$(uname -m)

SizeMountPoint1=$(df | grep "$MountPoint1" | cut -c1-20,51-55)
SizeMountPoint2=$(df | grep "$MountPoint2" | cut -c1-20,51-55)
SizeMountPoint3=$(df | grep "$MountPoint3" | cut -c1-20,51-55)
SizeMountPoint4=$(df | grep "$MountPoint4" | cut -c1-20,51-55)
SizeMountPoint5=$(df | grep "$MountPoint5" | cut -c1-20,51-55)

#NetDev1ip=$(/sbin/ifconfig "$NetworkDevice1" | grep "inet addr:" | sed "s/.*inet addr://" | sed "s/Bcast.*//")
#NetDev1down=$(/sbin/ifconfig "$NetworkDevice1" | grep bytes | sed 's/.*RX bytes:[0-9]* (//'  | sed 's/iB).*TX.*//' | sed 's/b).*TX.*//' | sed 's/).*TX.*//')
#NetDev1up=$(/sbin/ifconfig "$NetworkDevice1" | grep bytes | sed 's/.*TX bytes:[0-9]* (//' | sed 's/iB)//' |sed 's/b).*//' | sed 's/).*//')

#NetDev2ip=$(/sbin/ifconfig "$NetworkDevice1" | grep "inet addr:" | sed "s/.*inet addr://" | sed "s/Bcast.*//")
#NetDev2down=$(/sbin/ifconfig "$NetworkDevice1" | grep bytes | sed 's/.*RX bytes:[0-9]* (//'  | sed 's/iB).*TX.*//' | sed 's/b).*TX.*//' | sed 's/).*TX.*//')
#NetDev2up=$(/sbin/ifconfig "$NetworkDevice1" | grep bytes | sed 's/.*TX bytes:[0-9]* (//' | sed 's/iB)//' |sed 's/b).*//' | sed 's/).*//')

DateDate=$(date '+Date: %m.%d.%Y (%a)')
DateWeek=$(date '+Week: %W')
 DateDay=$(date '+ Day: %j')
DateTime=$(date '+Time: %I:%M [%Z]')
UpTime=$(uptime | sed 's/.* up //' | sed 's/[0-9]* us.*//' | sed 's/ day, /d/' | sed 's/ days, /d /' | sed 's/:/h /' | sed 's/ min//'|  sed 's/,/m/' | sed 's/  / /') 

MemTotal=$(echo "scale = 2; ("$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}' | sed 's/k//')" /1024)" | bc)
 MemFree=$(echo "scale = 2; ("$(cat /proc/meminfo | grep MemFree: | awk '{print $2}' | sed 's/k//')" /1024) + ("$(cat /proc/meminfo | grep grep -m 1 Cached: | awk '{print $2}' | sed 's/k//')" /1024)" | bc)
 MemUsed=$(echo "scale = 2; ("$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}' | sed 's/k//')" /1024) - (("$(cat /proc/meminfo | grep MemFree: | awk '{print $2}' | sed 's/k//')" /1024) + ("$(cat /proc/meminfo | grep -m 1 Cached: | awk '{print $2}' | sed 's/k//')" /1024))" | bc)

SwpTotal=$(echo "scale = 2; ("$(cat /proc/meminfo | grep SwapTotal: | awk '{print $2}' | sed 's/k//')" /1024)" | bc)
 SwpFree=$(echo "scale = 2; ("$(cat /proc/meminfo | grep SwapFree: | awk '{print $2}' | sed 's/k//')" /1024)" | bc)
 SwpUsed=$(echo "scale = 2; ("$(cat /proc/meminfo | grep SwapTotal: | awk '{print $2}' | sed 's/k//')" /1024) - ("$(cat /proc/meminfo | grep SwapFree: | awk '{print $2}' | sed 's/k//')" /1024)" | bc)

MemUsedPercent=$(echo "scale = 2; (("$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}' | sed 's/k//')" /1024) - (("$(cat /proc/meminfo | grep MemFree: | awk '{print $2}' | sed 's/k//')" /1024) + ("$(cat /proc/meminfo | grep -m 1 Cached: | awk '{print $2}' | sed 's/k//')" /1024))) / ("$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}' | sed 's/k//')" /1024) *100" | bc)
SwpUsedPercent=$(echo "scale = 2; (("$(cat /proc/meminfo | grep SwapTotal: | awk '{print $2}' | sed 's/k//')" /1024) - ("$(cat /proc/meminfo | grep SwapFree: | awk '{print $2}' | sed 's/k//')" /1024)) / ("$(cat /proc/meminfo | grep SwapTotal: | awk '{print $2}' | sed 's/k//')" /1024) *100" | bc)

CPUmodel=$(cat /proc/cpuinfo | grep "model name" | sed 's/.*: //')
CPUfreq=$(cat /proc/cpuinfo | grep -m 1 "cpu MHz" | sed 's/.*: //' | cut -c1-4)
CPUcache=$(cat /proc/cpuinfo | grep -m 1 "cache size" | sed 's/.*: //')


echo "<openbox_pipe_menu>"
echo "<separator label = \"Mountpoint ~ Space Used\"/>"
test "$SizeMountPoint1" && echo "<item label=\"$SizeMountPoint1\"/>"
test "$SizeMountPoint2" && echo "<item label=\"$SizeMountPoint2\"/>"
test "$SizeMountPoint3" && echo "<item label=\"$SizeMountPoint3\"/>"
test "$SizeMountPoint4" && echo "<item label=\"$SizeMountPoint4\"/>"
test "$SizeMountPoint5" && echo "<item label=\"$SizeMountPoint5\"/>"

echo "<separator label=\"Hardware ~ Use\"/>"
echo "<item label=\"RAM used: $MemUsedPercent%\"/>"
echo "<item label=\"Swap used: $SwpUsedPercent%\"/>"
echo "<item label=\"Cpu-Freq: $CPUfreq MHz\"/>"
echo "<item label=\"Signal: $Signal%\"/>"

#echo "<separator label = \"Network ~ "$NetworkDevice2"  \"/>"
#echo "<item label=\""$NetworkDevice1" ~         ip: $NetDev2ip\"/>"
#echo "<item label=\""$NetworkDevice1" ~ downloaded: "$NetDev2down"iB\"/>"
#echo "<item label=\""$NetworkDevice1" ~   uploaded: "$NetDev2up"iB\"/>"

echo "<separator label = \"Date ~ Time\"/>"
echo "<item label=\"$DateDate\"/>"
echo "<item label=\"$DateTime\"/>"
echo "<item label=\"Uptime: $UpTime\"/>"

echo "</openbox_pipe_menu>"
