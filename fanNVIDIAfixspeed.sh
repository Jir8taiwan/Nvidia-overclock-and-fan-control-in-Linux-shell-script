#!/bin/bash
# ##############################################
# Nvidia GPUs control functions in command line
# for:
# power output limit
# overclock core and mem
# fan speed fixing
# show temp and fan
# 
# version 20220630-1
# ##############################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

### Environment config
## 
#Alldevices=3
#XWin="/run/lxdm/lxdm-\:0.auth" #Please check owned auth location, and mine is lxde.
XWin="$HOME/.Xauthority"
Fanspeed=85 #Please check expecting percentage for static, and mine is 85%.
#Logfile="/dev/shm/fanNVIDIAfixspeed.log"

### Calculate varies
Alldevices=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | wc -l)
ID=$(( $Alldevices - 1 ))
##echo $Alldevices
##echo $ID
test ! -e $XWin && echo "The Xwin auth file '$XWin' DO NOT exist, and plese check config" && exit 0
SERVICE="Xorg"
if nvidia-smi -q | grep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running ..."
    echo ""
else
    echo "$SERVICE stopped in nvidia-smi of process, please check system in advanced or run startX first to use this tool script."
    exit 0
fi

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
exit 0
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
exit 0
}


### Overclock test funciton in array way
function overclock2(){
## Array define
## It can adjust gpu list to go in below format requirement
## (ID num : Core : MEM)
gpu=(0:50:200)
gpu+=(1:50:200)
gpu+=(2:50:0)
## ToDo calculate
#echo "Array length: ${#gpu[@]}"
#echo "Array data: ${gpu[@]}"
#echo ""
arrlen=${#gpu[@]}
for ((i=0; i < ${#gpu[@]}; i++))
do
#echo "data: $i ${gpu[$i]}"
#echo ""
dataid=$(echo ${gpu[$i]} | cut -d ":" -f 1)
datacore=$(echo ${gpu[$i]} | cut -d ":" -f 2)
datamem=$(echo ${gpu[$i]} | cut -d ":" -f 3)
echo "Arry $i , ID $dataid , CORE $datacore , MEM $datamem , Total $arrlen"
DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings --assign "[gpu:$dataid]/GPUGraphicsClockOffset[3]=$datacore" 
DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings --assign "[gpu:$dataid]/GPUMemoryTransferRateOffset[3]=$datamem" 
sleep 2
done
unset gpu
exit 0
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
exit 0
}


## overclock appointed GPU with a core/mem value alone in an ID
function occoremem(){
#echo "OC: $0 ID: $1 CORE $2 MEM $3"
#exit 0
gpuid=$1
gpucore=$2
gpumem=$3
#string check as right format with values
if [[ -z $gpuid ]]; then
	echo "oc format error, missing #ID number."
	exit 0
fi
if [[ $gpuid > $ID ]]; then
	echo "oc format wrong, #ID number is not existed."
	exit 0
fi
if [[ -z $gpucore ]]; then
	echo "oc format error, missing #Core value."
	exit 0
fi
if [[ -z $gpumem ]]; then
	echo "oc format error, missing #Mem value."
	exit 0
fi
#go on processing
echo "Overclock the GPU $gpuid to have CORE $gpucore and MEM $gpumem"
echo ""
DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings -a [gpu:$gpuid]/GPUGraphicsClockOffset[3]=$gpucore
sleep 1
DISPLAY=:0 XAUTHORITY=$Xwin /usr/bin/nvidia-settings -a [gpu:$gpuid]/GPUMemoryTransferRateOffset[3]=$gpumem
sleep 1
exit 0
}

## powerlimit appointed GPU watt value alone in an ID
gpupowerlimit(){
gpuid=$1
gpupl=$2
#string check as right format with values
if [[ -z $gpuid ]]; then
	echo "pl format error, missing #ID number."
	exit 0
fi
if [[ $gpuid > $ID ]]; then
	echo "pl format wrong, #ID number is not existed."
	exit 0
fi
if [[ -z $gpupl ]]; then
	echo "pl format error, missing #WATT value."
	exit 0
fi
#go on processing
echo "Overclock the GPU $gpuid to have POWERCHOKE $gpupl watt"
echo ""
sudo nvidia-smi -i $gpuid -pl $gpupl
sleep 1
exit 0
}

## fix all GPUs with same fan speed in once
fixallfanspeed(){
allfanspeed=$1
if [[ -z $allfanspeed ]]; then
	echo "fan format error, missing #FAN value."
	exit 0
fi
if [[ $allfanspeed < 0 ]]; then
	echo "fan format wrong, #FAN value is out of range 0-100 percentage."
	exit 0
fi
if [[ $allfanspeed > 100 ]]; then
	echo "fan format wrong, #FAN value is out of range 0-100 percentage."
	exit 0
fi
echo "fix all GPUs fan speed to $allfanspeed"
for List in $(seq 0 $ID)
do
DISPLAY=:0 XAUTHORITY=$XWin nvidia-settings -a [gpu:$List]/GPUFanControlState=1
DISPLAY=:0 XAUTHORITY=$XWin nvidia-settings -a [fan:$List]/GPUTargetFanSpeed=$allfanspeed
sleep 1
done
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
  "overclock2")
	overclock2
	;;
  "fixfanspeed")
    fixfanspeed
    ;;
  "showinfo")
    showalltempfan
    ;;
  "oc")
    occoremem $2 $3 $4
    #echo "ID: $2 CORE $3 MEM $4"
    ;;
  "pl")
    gpupowerlimit $2 $3
    ;;
  "fan")
    fixallfanspeed $2
    ;;
  *)
	echo "./fanNVIDIAfixspeed.sh"
	echo "Usage ${0} {all | powerlimit | overclock | fixfanspeed | showinfo | oc | pl | fan}"
	echo "all          : for all functino of need"
	echo "powerlimit   : for specificed cards of watt"
	echo "overclock    : for specificed catds of core/mem"
	echo "fixfanspeed  : for specificed speed percentage"
	echo "showinfo     : for information in all GPUs of temp/fan speed"
	# added oc alone in each card
	echo ""
	echo "oc #ID[num] #CORE[+/-num] #MEM[+/-num] 	: for overclock appointed GPU with core/mem modification"
	echo "EX: ./fanNVIDIAfixspeed.sh oc 0 -50 +200"
	echo "pl #ID[num] #WATT[num] 	: for choke appointed GPU with powerlimit output"
	echo "EX: ./fanNVIDIAfixspeed.sh pl 1 75        as same as \"sudo nvidia-smi -i 1 -pl 75\""
	echo "fan #FAN[percentage] 	: for fix all GPUs with appointed fan speed percentage"
	echo "EX: ./fanNVIDIAfixspeed.sh fan 85"
	;;
esac
