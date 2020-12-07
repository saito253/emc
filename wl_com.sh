#!/bin/bash

sudo ifconfig wlan0 down

#Output of running Wi-Fi script:
#sudo ./wl down
#sudo ./wl mpc 0
#sudo ./wl phy_watchdog 0
#sudo ./wl glacial_timer 0x7fffffff
#sudo ./wl country ALL
#sudo ./wl band b
#sudo ./wl 2g_rate -h 7 -b 20
#sudo ./wl chanspec 7/20

#Chanspec set to 0x1007
#sudo ./wl scansuppress 1
#sudo ./wl up
#sudo ./wl phy_forcecal 1
#sudo ./wl phy_txpwrctrl 1
#sudo ./wl txpwr1 -1
#sudo ./wl txpwr1 -o -d 12
#sudo ./wl pkteng_start 00:11:22:33:44:55 tx 20 1024 0

echo -n INPUT_TRX[tx, rx]:
read trx

echo -n INPUT_MODE[b:802.11b, g:802.11b, n:802,11b]:
read mode

if [ $mode = "b" ]; then
echo -n INPUT_RATE[1, 2, 5.5, 11]:
elif [ $mode = "g" ]; then
echo -n INPUT_RATE[6, 9, 12, 18, 24, 36, 48, 54]:
elif [ $mode = "n" ]; then
echo -n INPUT_MCS_index[0, 1, 2, 3, 4, 5, 6, 7]:
fi
read rate

echo -n INPUT_CHANNEL[1-13 max channel]: # max channel: JP: 14,  US/CA: 11, EU:13
read ch

if [ $trx = "tx" ]; then
	echo -n INPUT_POWER[-1 max power...12]:
read pw
else
pw="-1"
fi

echo "-------------- Input summary ------------"
echo "TRX :           "$trx
echo "Mode :          "$mode
echo "Rate or Index : "$rate
echo "Channel :       "$ch
echo "Power :         "$pw
echo "-----------------------------------------"

sudo ./wl ver
sudo ./wl down
sudo ./wl mpc 0
sudo ./wl phy_watchdog 0
sudo ./wl country ALL		    # US/911, EU/116, JP/101, CA/938
sudo ./wl band b
if [ $mode = "b" ]; then 	    #802.11b
sudo ./wl 2g_rate -r $rate          # Note: (where r can be 1, 2, 5.5 or 11)
elif [ $mode = "g" ]; then 	    #802.11g
sudo ./wl 2g_rate -r $rate          # Note: (where r can be 6, 9, 12, 18, 24, 36, 48, 54)
elif [ $mode = "n" ]; then 	    #802.11n
sudo ./wl 2g_rate -h $rate -b 20    # Note: (where h can be 0, 1, 2, 3, 4, 5, 6 or 7)
#sudo ./wl 2g_rate -h 7 -b 20
fi
sudo ./wl chanspec $ch 		    # Note: (1 = 0x1001, chanspec can be set from 1?14 here following HT20 table)
sudo ./wl up
sudo ./wl phy_forcecal 1
sudo ./wl phy_activecal

if [ $pw = "-1" ]; then 
sudo ./wl txpwr1 -1
else
sudo ./wl txpwr1 -o -d $pw
fi

sudo ./wl scansuppress 1

if [ $trx = "tx" ]; then
sudo ./wl pkteng_start 00:11:22:33:44:55 tx 100 1024 0
echo -n INPUT_STOP[Enter]:
read stop
sudo ./wl pkteng_stop tx
elif [ $trx = "rx" ]; then
sudo ./wl pkteng_start 00:11:22:33:44:55 rx
echo -n INPUT_STOP[Enter]:
read stop
sudo ./wl counters
sudo ./wl pkteng_stop rx
fi

sudo ./wl down
sudo hciconfig hci0 down 			        # command to disable the HCI
