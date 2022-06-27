# Nvidia-overclock-and-fan-control-in-Linux-shell-script

 Nvidia GPUs control functions in command line
 for:
 power output limit
 overclock core and mem
 fan speed fixing
 show temp and fan

 The latest version 20220627-2


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
 
 oc [ID] [CORE] [MEM]: overclock the appointed GPU id to tune core/mem alone
 
 EX: oc 1 50 -100  (means ID 1 core +50 mem -100)

--

If this small code is helping and useful after application, it can donate BCH coin to me for encourage as following address: 

# bitcoincash:qq6ghvdmyusnse9735rd5q09ensacl8z8qzrlwf49q

Thank you very much.

