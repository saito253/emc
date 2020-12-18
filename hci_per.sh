#!/bin/bash

# hcitool, hciconfig, hciattach

bluetoothctl version

sudo ifconfig wlan0 down
sudo ./wl down

sudo hciconfig hci0 down 			# command to disable the HCI
#---------------Command BlueZ Format: hcitool cmd OGF OCF Parameter(s)
sudo hciconfig hci0 up 				# command to enable the HCI
sudo hcitool -i hci0 cmd 0x03 0x003 		# HCI_Reset 
sudo hcitool -i hci0 cmd 0x06 0x003 		# HCI_Enable_Device_Under_Test_Mode 
sudo hcitool -i hci0 cmd 0x03 0x005 0x000	# HCI_Set_Event_Filter 
sudo hcitool -i hci0 cmd 0x03 0x01A 		# HCI_Write_Scan_Enable 

echo -n INPUT_TRX[tx, rx]:
read trx

#echo -n INPUT_PACKET_TYPE[DM1/DM3/DM5/DH1/DH3/DH5/HV1/HV2/HV3]:
#read ptype
#echo $ptype
#sudo hciconfig ptype=$ptype 			# Packet type: DM1 DM3 DM5 DH1 DH3 DH5 HV1 HV2 HV3

#sudo hcitool cmd 0x03 0x0C 0x00 			#HCI_Reset
#sudo hcitool cmd 0x05 0x0C 0x03 0x021 0x002 0x023 	#HCI_Set_Event_Filter 
#sudo hcitool cmd 0x1A 0x0C 0x01 0x034 			#HCI_Write_Scan_Enable 
#sudo hcitool cmd 0x03 0x18 0x00 		        #HCI_Enable_Device_Under_Test_Mode

BDADDR=`sudo hcitool -i hci0 dev | nawk '/hci0/{print $2}'`
echo $BDADDR

#if [ $trx = "tx" ]; then
#echo -n INPUT_POWER[0-F]:
#read pw
#echo $pw
#sudo hcitool -i hci0 tpl $DBADDR $pw
#sudo hcitool -i hci0 cmd 0x03 0x002D 0x0$pw 		# HCI_Read_Transmit_Power_Level
#sudo hcitool -i hci0 cmd 0x03 0x002D $pw 		# HCI_Read_Transmit_Power_Level
#sudo hcitool -i hci0 cmd 0x3f 0x00 0x0$pw 		# HCI_EXT_SetTxPowerCmd
#sudo hcitool inqtpl pw
#fi


#0=2402MHz、Channel Step=2MHz
echo -n INPUT_CHANNEL[0x00:2402MHz,0x13:2440MHz,0x27:2480MHz]:
read ch

if [ $trx = "tx" ]; then
sudo hcitool -i hci0 cmd 0x08 0x1e $ch 0x03 0x00 # LE Transmitter Test
#sudo hcitool -i hci0 cmd 0x08 0x34 $ch 0x03 0x00 # LE Enhanced Transmitter Test
elif [ $trx = "rx" ]; then
sudo hcitool -i hci0 cmd 0x08 0x1d $ch           # LE Receiver Test
#sudo hcitool -i hci0 cmd 0x08 0x33 $ch           # LE Enhanced Receiver Test
fi

echo -n INPUT_STOP[Enter]:
read stop
#sudo hcitool -i hci0 cmd 0x03 0x035     # HCI_Host_Number_Of_Completed_Packets
result=$(sudo hcitool -i hci0 cmd 0x08 0x1f)	# LE Test End
echo $result
if [ $trx = "rx" ]; then
result_d=$(echo $result | nawk '{print "obase=10; ibase=16; "$NF$(NF-1)}' | bc)
echo "--------------------------------------------"
echo "   Recived number of packets : "$result_d
echo "--------------------------------------------"
fi
sudo ./wl down
sudo hciconfig hci0 down 			        # command to disable the HCI

exit
