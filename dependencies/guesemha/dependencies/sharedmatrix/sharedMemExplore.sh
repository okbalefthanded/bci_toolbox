#!/bin/bash

cat /proc/sys/kernel/shmall

TotalKbytes=`awk '/MemTotal:/ { print $2 }' /proc/meminfo`
TotalBytes=`expr $TotalKbytes \* 1024`
PageSize=`getconf PAGE_SIZE`

#ShmallValue=`expr $TotalBytes / $PageSize / 2`
ShmallValue=`expr $TotalBytes / $PageSize`
ShmmaxValue=$TotalBytes

echo $ShmallValue

#So, for a 64 GB RAM, 64 bit system…
#That is 64 GB – 4 GB RAM = 60 GB SHMMAX
#ANd, SHMALL = 60 GB / 4096 = 15 MB SHMALL

#echo $ShmallValue > /proc/sys/kernel/shmall
#sysctl -p
#cat /proc/sys/kernel/shmall

