# Nvidia-overclock-and-fan-control-in-Linux-shell-script

 Nvidia GPUs control functions in command line
 for:
 power output limit
 overclock core and mem
 fan speed fixing
 show temp and fan

 version 20220626-1


1. make the script exacutable

chmod +x ./fanNVIDIAfixspeed.sh

2. modify environment to fit usage

nano ./fanNVIDIAfixspeed.sh

3. run with option to call function needs

./fanNVIDIAfixspeed.sh

 Usage ./fanNVIDIAfixspeed.sh {all|powerlimit|overclock|fixfanspeed|showalltempfan}
 
 all: all four options
 
 powerlimit: define in the function and modify need
 
 overclock:  define in the function and modify need
 
 fixfanspeed:  define in config and auto run all gpus in system
 
 showalltempfan: show csv format in all gpus of temp and fan speed
 

--

If this small code is helping and useful after application, it can donate BCH coin to me for encourage as following address: 

# bitcoincash:qq6ghvdmyusnse9735rd5q09ensacl8z8qzrlwf49q

Thank you very much.

