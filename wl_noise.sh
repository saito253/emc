#!/bin/bash

TARGET_SERVER=192.168.20.100

sudo ifconfig wlan0 down
sudo ifconfig wlan0 up
sudo hciconfig hci0 down 			        # command to disable the HCI

trx=tx

echo -n INPUT_MODE[b:802.11b, g:802.11g, n:802.11n]:
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

echo -n "INPUT_TEST_SECOND[>= 0, 0 is infinity]:" # netperf test second
read TEST_SEC

echo "-------------- Input summary ------------"
echo "TRX :           "$trx
echo "Mode :          "$mode
echo "Rate or Index : "$rate
echo "Channel :       "$ch
echo "Power :         "$pw
echo "TEST SECOND :   "$TEST_SEC
echo "-----------------------------------------"

sudo ./wl ver
sudo ./wl reset_cnts  # ??
sudo ./wl out         # ??
sudo ./wl down
sudo ./wl frameburst 0 # ??
sudo ./wl ampdu 1      # ??
sudo ./wl bi 65000     # ??
sudo ./wl mpc 0
sudo ./wl phy_watchdog 0
sudo ./wl country JP	    # ALL, US/911, EU/116, JP/101, CA/938
#sudo ./wl country ALL	    # ALL, US/911, EU/116, JP/101, CA/938
sudo ./wl txchain 1    # ??
sudo ./wl mimo_bw_cap 1 # ??
sudo ./wl band b
if [ $mode = "b" ]; then 	    #802.11b
sudo ./wl 2g_rate -r $rate          # Note: (where r can be 1, 2, 5.5 or 11)
elif [ $mode = "g" ]; then 	    #802.11g
sudo ./wl 2g_rate -r $rate          # Note: (where r can be 6, 9, 12, 18, 24, 36, 48, 54)
elif [ $mode = "n" ]; then 	    #802.11n
sudo ./wl 2g_rate -h $rate -b 20    # Note: (where h can be 0, 1, 2, 3, 4, 5, 6 or 7)
fi
sudo ./wl chanspec $ch 		    # Note: (1 = 0x1001, chanspec can be set from 1?14 here following HT20 table)
sudo ./wl up
sudo ./wl phy_forcecal 1
#sudo ./wl phy_activecal  ###
#sudo ./wl join Pi3-AP key C73jFi9on2 amode wpa2psk # ??
#sudo ./wl join Pi3-AP amode wpa2psk # ??


if [ $pw = "-1" ]; then 
sudo ./wl txpwr1 -1
else
sudo ./wl txpwr1 -o -d $pw
fi

sudo ./wl status                    # Shows if STA/Client device connected to the Access Point.
sudo ./wl phy_ed_thresh -70         # adjust the Energy Detect (Adaptivity) sensitivity level. Range is from -20 to -75, but never below -75

#sudo ./wl scansuppress 1


echo "Wait WiFi Connection"
ping -c 1 192.168.20.100
while [ $? != 0 ]; do
  sleep 3
  ping -c 1 192.168.20.100
done


echo "Start netperf. Stop Ctrl-C "
#iperf -c $TARGET_SERVER -u -b -l -i 1 -i 10000
netperf -H $TARGET_SERVER -t UDP_STREAM -l $TEST_SEC -- -m 1024

sudo ./wl counters

#sudo ./wl down
#sudo hciconfig hci0 down   # command to disable the HCI

