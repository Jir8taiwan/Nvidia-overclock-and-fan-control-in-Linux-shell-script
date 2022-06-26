#!/bin/bash
# ##############################################
# Nvidia GPUs control functions in command line
# for:
# power output limit
# overclock core and mem
# fan speed fixing
# show temp and fan
#
# version 20220626-2
# ##############################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

### Environment config
## 
#Alldevices=3
XWin="/run/lxdm/lxdm-\:0.auth" #Please check owned auth location, and mine is lxde.
Fanspeed=85 #Please check expecting percentage for static, and mine is 85%.
#Logfile="/dev/shm/fanNVIDIAfixspeed.log"

### Calculate varies
Alldevices=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | wc -l)
ID=$(( $Alldevices - 1 ))
##echo $Alldevices
##echo $ID

### Powerload limit output
## It can add or delete the need of gpus IDs and power watt limit.
## My default is 3 cards and 65/67/70 watts.
#
function powerlimit(){
echo "Powerload limit output"
sudo nvidia-smi -i 0 -pl 65
sudo nvidia-smi -i 1 -pl 67
sudo nvidia-smi -i 2 -pl 70
sleep 2
}

### Overclock core and mem
## It can add or delete the need of gpus IDs and specified core/mem.
## My default is 3 cards.
## ID0 core +50 mem +200
## ID1 core +50 mem +200
## ID2 core +50 mem 0
function overclock(){
DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings --assign "[gpu:0]/GPUGraphicsClockOffset[3]=50" --assign "[gpu:0]/GPUMemoryTransferRateOffset[3]=200"
sleep 2

DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings --assign "[gpu:1]/GPUGraphicsClockOffset[3]=50" --assign "[gpu:1]/GPUMemoryTransferRateOffset[3]=200" 
sleep 2

DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings --assign "[gpu:2]/GPUGraphicsClockOffset[3]=50" --assign "[gpu:2]/GPUMemoryTransferRateOffset[3]=0" 
sleep 2
}

### Fan speed fixing to 85 persontage
#
#DISPLAY=:0 XAUTHORITY=/run/lxdm/lxdm-\:0.auth nvidia-settings -a [gpu:0]/GPUFanControlState=1
#DISPLAY=:0 XAUTHORITY=/run/lxdm/lxdm-\:0.auth nvidia-settings -a [fan:0]/GPUTargetFanSpeed=$Fanspeed
#sleep 2
#
#DISPLAY=:0 XAUTHORITY=/run/lxdm/lxdm-\:0.auth nvidia-settings -a [gpu:1]/GPUFanControlState=1
#DISPLAY=:0 XAUTHORITY=/run/lxdm/lxdm-\:0.auth nvidia-settings -a [fan:1]/GPUTargetFanSpeed=$Fanspeed
#sleep 2
#
#DISPLAY=:0 XAUTHORITY=/run/lxdm/lxdm-\:0.auth nvidia-settings -a [gpu:2]/GPUFanControlState=1
#DISPLAY=:0 XAUTHORITY=/run/lxdm/lxdm-\:0.auth nvidia-settings -a [fan:2]/GPUTargetFanSpeed=$Fanspeed
#sleep 2
#
## FOR loop way to call all GPUs automatically
function fixfanspeed(){
echo "Todo fan speed fixing to" $Fanspeed 
for List in $(seq 0 $ID)
do
DISPLAY=:0 XAUTHORITY=$XWin nvidia-settings -a [gpu:$List]/GPUFanControlState=1
DISPLAY=:0 XAUTHORITY=$XWin nvidia-settings -a [fan:$List]/GPUTargetFanSpeed=$Fanspeed
sleep 1
done
}


## Show current temp and fan speed for all GPUs
function showalltempfan(){
echo "All GPUs temp and fan speed"
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
nvidia-smi --query-gpu=fan.speed --format=csv,noheader
sleep 1
}

## Case to call in sub command
## If command line of option is too many words, it can modify to fit by self.
echo "This shell script will run your selection !"
case ${1} in
  "all")
	powerlimit
	overclock
	fixfanspeed
	showalltempfan
	;;
  "powerlimit")
	powerlimit
	;;
  "overclock")
	overclock
	;;
  "fixfanspeed")
        fixfanspeed
        ;;
  "showalltempfan")
        showalltempfan
        ;;
  *)
	echo "Usage ${0} {all|powerlimit|overclock|fixfanspeed|showalltempfan}"
	echo "all : for all functino of need"
	echo "powerlimit : for specificed cards of watt"
	echo "overclock : for specificed catds of core/mem"
	echo "fixfanspeed : for specificed speed percentage"
	echo "showalltempfan : for information in all GPUs of temp/fan speed"
	;;
esac

